locals {
  challenge_number = var.challenge_number

  common_tags = {
    Project      = "formacao-aws"
    Environment  = "lab"
    Owner        = "nilo-lima-jr"
    ManagedBy    = "terraform"
    Challenge    = "mai2026-desafio-${local.challenge_number}"
    CostCenter   = "formacao-aws-mai2026"
    AutoShutdown = "true"
  }
}
