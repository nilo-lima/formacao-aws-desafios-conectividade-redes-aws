# ═══════════════════════════════════════════════════════════════════
# main.tf — Desafio 01: VPC + Subnet Pública
# Camada de rede via shared/modules/vpc
# ═══════════════════════════════════════════════════════════════════

module "vpc" {
  source = "../../shared/modules/vpc"

  name            = "desafio-01"
  cidr_block      = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = []

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags
}
