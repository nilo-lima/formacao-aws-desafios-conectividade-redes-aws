variable "region" {
  type    = string
  default = "us-east-1"
}

variable "challenge_number" {
  type    = string
  default = "03"
}

variable "public_key_path" {
  description = "Caminho para a chave pública SSH Ed25519 (Linux)"
  type        = string
  default     = "~/.ssh/bia-lab-03.pub"
}

variable "windows_public_key_path" {
  description = "Caminho para chave pública RSA (Windows AMIs nao suportam Ed25519)"
  type        = string
  default     = "~/.ssh/bia-lab-03-win.pub"
}

variable "enable_windows" {
  description = "Se true, provisiona EC2 Windows Server 2022 (t3.micro) na subnet privada"
  type        = bool
  default     = true
}

variable "admin_cidr" {
  description = "CIDR com acesso SSH ao bastion (use seu IP em producao)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "rds_password" {
  description = "Senha do RDS PostgreSQL (minimo 8 caracteres)"
  type        = string
  sensitive   = true
}
