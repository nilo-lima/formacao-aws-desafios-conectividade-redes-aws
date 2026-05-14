# ─── AMI: Amazon Linux 2023 (última versão estável) ──────────────
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ─── IAM Instance Profile existente ──────────────────────────────
data "aws_iam_instance_profile" "ssm" {
  name = "role-acesso-ssm"
}
