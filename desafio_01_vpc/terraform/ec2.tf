# ═══════════════════════════════════════════════════════════════════
# ec2.tf — Security Group e instância bia-dev
# ═══════════════════════════════════════════════════════════════════

# ─── Security Group (criado na nova VPC — ADR-002) ───────────────
resource "aws_security_group" "bia_dev" {
  name        = "bia-dev"
  description = "Acesso HTTP e API BIA; sem porta 22 (SSM via IAM)"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Frontend Vite"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "API Express BIA"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "bia-dev" })
}

# ─── EC2 bia-dev (zona A — us-east-1a) ───────────────────────────
resource "aws_instance" "bia_dev" {
  ami           = var.ec2_ami != "" ? var.ec2_ami : data.aws_ami.amazon_linux_2023.id
  instance_type = var.ec2_instance_type

  subnet_id              = module.vpc.public_subnet_ids[0]
  key_name               = "test-key"
  vpc_security_group_ids = [aws_security_group.bia_dev.id]
  iam_instance_profile   = data.aws_iam_instance_profile.ssm.name

  user_data = file("${path.module}/../scripts/user_data_ec2_zona_a.sh")

  # IMDSv2 obrigatório (segurança)
  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    http_endpoint               = "enabled"
  }

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_type           = "gp3"
    volume_size           = 20
    tags                  = merge(local.common_tags, { Name = "bia-dev-root" })
  }

  tags = merge(local.common_tags, { Name = "bia-dev" })
}
