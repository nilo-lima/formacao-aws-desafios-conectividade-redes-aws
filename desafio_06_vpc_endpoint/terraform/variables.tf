variable "region" {
  description = "Regiao AWS principal"
  type        = string
  default     = "us-east-1"
}

variable "challenge_number" {
  description = "Numero do desafio (usado nas tags e nomes de recursos)"
  type        = string
  default     = "06"
}

# ─── Rede ────────────────────────────────────────────────────────────────────

variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidr" {
  description = "CIDR da subnet privada"
  type        = string
  default     = "10.0.2.0/24"
}

variable "az" {
  description = "Availability Zone"
  type        = string
  default     = "us-east-1a"
}

# ─── Compute ─────────────────────────────────────────────────────────────────

variable "instance_type" {
  description = "Tipo da instancia EC2"
  type        = string
  default     = "t3.micro"
}
