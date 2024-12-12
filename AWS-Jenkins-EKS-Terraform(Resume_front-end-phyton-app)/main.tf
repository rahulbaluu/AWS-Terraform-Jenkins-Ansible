resource "aws_vpc" "myvpc" {
  cidr_block = var.vpc-cidr
  tags = {
    Name = "jenkins"
    Environment = "Dev"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "My-Internet-Gateway"
  }
}

# Create a route to the Internet Gateway for public access
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.myvpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = var.public_subnets
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "jenkins-subnet"
    Environment = "Dev"
  }
}

resource "aws_security_group" "webSg" {
  name   = var.sg-name
  vpc_id = aws_vpc.myvpc.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = -1
  }

  tags   = {
    Name = "jenkins server security group"
    Environment = "Dev"
  }
}


resource "aws_instance" "server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = "demo"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.subnet.id
  associate_public_ip_address = true

  connection {
    type        = "ssh"
    user        = "ubuntu"  # Replace with the appropriate username for your EC2 instance
    private_key = file("~/Downloads/demo.pem")  # Replace with the path to your private key
    host        = self.public_ip
  }

   tags = {
    Name = "My EC2 Server"
    Environment = "Dev"
  }

   # copy the install_jenkins.sh file from your computer to the ec2 instance 
  provisioner "file" {
    source      = "jenkins-install.sh"
    destination = "/tmp/jenkins-install.sh"
  }

  # set permissions and run the install_jenkins.sh file
  provisioner "remote-exec" {
    inline = [
        "sudo chmod +x /tmp/jenkins-install.sh",
        "sh /tmp/jenkins-install.sh",
    ]
  }

  # wait for ec2 to be created
  depends_on = [aws_instance.server]
}