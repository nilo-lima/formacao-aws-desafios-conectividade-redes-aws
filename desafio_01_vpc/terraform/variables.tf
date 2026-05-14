variable "region" {
  type    = string
  default = "us-east-1"
}

variable "challenge_number" {
  type    = string
  default = "01"
}

variable "ec2_instance_type" {
  description = "Tipo da instância EC2 bia-dev"
  type        = string
  default     = "t3.micro"
}

variable "ec2_ami" {
  description = "AMI override para bia-dev. Vazio = usa data source Amazon Linux 2023 mais recente."
  type        = string
  default     = ""
}
