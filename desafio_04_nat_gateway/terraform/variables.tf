variable "region" {
  type    = string
  default = "us-east-1"
}

variable "challenge_number" {
  type    = string
  default = "04"
}

variable "rds_password" {
  description = "Senha do PostgreSQL (passar via TF_VAR_rds_password ou terraform.tfvars)"
  type        = string
  sensitive   = true
}
