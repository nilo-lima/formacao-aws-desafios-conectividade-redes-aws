locals {
  common_tags = {
    Project      = "formacao-aws"
    Environment  = "lab"
    Owner        = "nilo-lima-jr"
    ManagedBy    = "terraform"
    Challenge    = "mai2026-desafio-${var.challenge_number}"
    CostCenter   = "formacao-aws-mai2026"
    AutoShutdown = "true"
  }
}
