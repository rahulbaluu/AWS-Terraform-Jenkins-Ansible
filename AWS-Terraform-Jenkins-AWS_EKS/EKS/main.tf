resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc-cidr
  
  tags = {
    Name = "eks"
    Environment = "Dev"
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Create an Internet Gateway for public subnet access
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "My-EKS-Internet-Gateway"
    Environment = "Dev"
  }
}

# Create a NAT Gateway Elastic IP (EIP) for private subnet access
resource "aws_eip" "nat_eip" {
}

# Create a NAT Gateway in the public subnet
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id  # NAT Gateway should be in a public subnet

  tags = {
    Name        = "My-EKS-NAT-Gateway"
    Environment = "Dev"
  }
}

# Public Subnet with EKS and ELB Tag
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.public_subnets[0]  # CIDR block for the public subnet
  availability_zone = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = true  # Instances in the public subnet will get public IPs

  tags = {
    Name        = "eks-public-subnet"
    Environment = "Dev"
    "kubernetes.io/cluster/my-eks-cluster" = "shared"  # EKS cluster tag
    "kubernetes.io/role/elb" = "1"  # Tag for ELB resources
  }
}

# Private Subnet with EKS Tag (no ELB tag for private subnets)
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.private_subnets[0]  # CIDR block for the private subnet
  availability_zone = data.aws_availability_zones.available.names[0]

  map_public_ip_on_launch = false  # Instances in the private subnet will not get public IPs

  tags = {
    Name        = "eks-private-subnet"
    Environment = "Dev"
    "kubernetes.io/cluster/my-eks-cluster" = "shared"  # EKS cluster tag 
  }
}

# Public Route Table for public subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id  # Internet Gateway for public route
  }

  tags = {
    Name        = "Public-Route-Table"
    Environment = "Dev"
  }
}

# Associate Public Route Table with Public Subnet
resource "aws_route_table_association" "public_route_table_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Private Route Table for private subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id  # NAT Gateway for private route
  }

  tags = {
    Name        = "Private-Route-Table"
    Environment = "Dev"
  }
}

# Associate Private Route Table with Private Subnet
resource "aws_route_table_association" "private_route_table_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# EKS Cluster
resource "aws_eks_cluster" "my_eks" {
  name     = "my-eks-cluster"
  version = "1.30"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.public_subnet.id,
      aws_subnet.private_subnet.id
    ]
  }
  depends_on = [
    aws_internet_gateway.my_igw
  ]

  tags = {
    Name        = "my-eks-cluster"
    Environment = "Dev"
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })
  tags = {
    Name        = "eks-cluster-role"
    Environment = "Dev"
  }
}

# Attach the required policies for EKS cluster role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS Node Group
resource "aws_eks_node_group" "my_eks_nodes" {
  cluster_name    = aws_eks_cluster.my_eks.name
  node_group_name = "my-node-group"
  node_role_arn   = aws_iam_role.eks_worker_role.arn
  subnet_ids      = [aws_subnet.private_subnet.id]  # Worker nodes in the private subnet

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }

  disk_size = 20

  instance_types = [var.instance_type]

  depends_on = [
    aws_eks_cluster.my_eks
  ]
}

# IAM Role for EKS Worker Nodes
resource "aws_iam_role" "eks_worker_role" {
  name = "eks-worker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      }
    ]
  })

  tags = {
    Name        = "eks-worker-role"
    Environment = "Dev"
  }
}

# Attach the required policies for EKS worker node role
resource "aws_iam_role_policy_attachment" "eks_worker_policy_attachment" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_worker_eks_cni_policy_attachment" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSCNI"
}

resource "aws_iam_role_policy_attachment" "eks_worker_autoscaling_policy_attachment" {
  role       = aws_iam_role.eks_worker_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2AutoScaling"
}

# Security Group for the Node Group
resource "aws_security_group" "eks_security_group" {
  name        = "eks-node-sg"
  description = "Security group for EKS worker nodes"
  vpc_id      = aws_vpc.myvpc.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "eks-node-sg"
    Environment = "Dev"
  }
}