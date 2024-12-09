variable "region" {
    description = "Value for ami-id"
}

variable "instance_type" {
    description = "Value for Instance type"
    default = "t2.micro"
    type        = string
}

variable "ami_id" {
    description = "Value for ami-id"
    type        = string
}

variable "key_name" {
    description = "Value for Key name"
}

variable "sg-name" {
    description = "Name for Security group"
    type        = string
}

variable "vpc-cidr" {
    description = "Value for cidr"
    type = string
}

variable "public_subnets" {
  description = "CIDR block for public subnet."
  type        = string
  default     = "10.0.1.0/24"  # Example CIDR block, change it as per your requirements.
}

variable "subnet_az" {
    description = "Value for Availabilty zone of subnet"
}