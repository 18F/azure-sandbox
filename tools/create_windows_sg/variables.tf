variable "aws_key_path" {}
variable "aws_key_name" {}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "us-east-1"
}
variable "aws_default_vpc" {
    description = "AWS Default VPC"
}
