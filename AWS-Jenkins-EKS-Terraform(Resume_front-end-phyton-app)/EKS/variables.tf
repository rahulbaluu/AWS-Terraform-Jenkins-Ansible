variable "region" {
    description = "Value for ami-id"
    type = string
}

variable "vpc-cidr" {
    description = "Value for cidr"
    type = string
}

variable "public_subnets" {
  description = "CIDR block for public subnet."
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR block for public subnet."
  type        = list(string)
}

variable "instance_type" {
    description = "Value for Instance type"
    default = "t2.micro"
    type        = string
}