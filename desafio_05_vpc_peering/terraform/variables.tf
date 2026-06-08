variable "challenge_number" {
  description = "Numero do desafio (usado nas tags e nomes de recursos)"
  type        = string
  default     = "05"
}

# ─── CIDRs ──────────────────────────────────────────────────────────────────

variable "vpc_cidr_east1" {
  description = "CIDR da VPC em us-east-1"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_cidr_east2" {
  description = "CIDR da VPC em us-east-2"
  type        = string
  default     = "10.1.0.0/16"
}

variable "subnet_public_east1" {
  description = "CIDR da subnet publica em us-east-1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_public_east2" {
  description = "CIDR da subnet publica em us-east-2"
  type        = string
  default     = "10.1.1.0/24"
}

variable "az_east1" {
  description = "Availability Zone em us-east-1"
  type        = string
  default     = "us-east-1a"
}

variable "az_east2" {
  description = "Availability Zone em us-east-2"
  type        = string
  default     = "us-east-2a"
}

# ─── Compute ────────────────────────────────────────────────────────────────

variable "instance_type" {
  description = "Tipo da instancia EC2 em ambas as regioes"
  type        = string
  default     = "t3.micro"
}

variable "public_key" {
  description = "Conteudo da chave SSH publica (ex: cat ~/.ssh/id_rsa.pub)"
  type        = string
}

# ─── Seguranca ──────────────────────────────────────────────────────────────

variable "admin_cidr" {
  description = "CIDR autorizado para SSH externo (ex: SEU_IP/32). Use 0.0.0.0/0 apenas em lab de curta duracao."
  type        = string
  default     = "0.0.0.0/0"
}
