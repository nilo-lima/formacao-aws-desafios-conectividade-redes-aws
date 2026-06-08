# =============================================================================
# Desafio 06 - VPC Endpoint + SSM + EC2 Instance Connect
# EC2 em subnet 100% privada, sem NAT, sem IP publico
# Acesso via SSM Session Manager e EC2 Instance Connect Endpoint
# =============================================================================

# ─── AMI Amazon Linux 2023 ───────────────────────────────────────────────────

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ─── VPC (somente subnet privada) ────────────────────────────────────────────
# O modulo cria IGW e RT publica mesmo com public_subnets=[].
# Esses recursos existem mas sao inerts — nenhuma subnet e associada a eles.
# Ver ADR-001.

module "vpc" {
  source = "../../shared/modules/vpc"

  name            = "bia-vpc-06"
  cidr_block      = var.vpc_cidr
  azs             = [var.az]
  public_subnets  = []
  private_subnets = [var.private_subnet_cidr]
  tags            = local.common_tags
}

# ─── Observabilidade ─────────────────────────────────────────────────────────

module "obs" {
  source = "../../shared/modules/observability"

  name_prefix    = "bia-06"
  log_groups     = ["/bia/desafio-06/ec2"]
  retention_days = 7
  tags           = local.common_tags
}

# ─── IAM Role para SSM Session Manager ───────────────────────────────────────

resource "aws_iam_role" "ssm" {
  name = "bia-ssm-role-06"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "bia-ssm-profile-06"
  role = aws_iam_role.ssm.name
  tags = local.common_tags
}

# ─── Security Group: VPC Endpoints (Interface) ───────────────────────────────

resource "aws_security_group" "endpoints" {
  name        = "bia-sg-06-endpoints"
  description = "Permite HTTPS dos recursos da VPC para os endpoints Interface"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS from VPC CIDR"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "bia-sg-06-endpoints" })
}

# ─── Security Group: EC2 ─────────────────────────────────────────────────────

resource "aws_security_group" "ec2" {
  name        = "bia-sg-06-ec2"
  description = "EC2 privada: SSH via EIC Endpoint, saida HTTPS para SSM e S3"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "SSH via EC2 Instance Connect Endpoint"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.endpoints.id]
  }

  egress {
    description = "HTTPS para endpoints SSM e S3 Gateway"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "bia-sg-06-ec2" })
}

# ─── VPC Endpoints ───────────────────────────────────────────────────────────

module "vpc_endpoints" {
  source = "../../shared/modules/vpc-endpoints"

  name_prefix                = "bia-06"
  vpc_id                     = module.vpc.vpc_id
  region                     = var.region
  private_subnet_ids         = module.vpc.private_subnet_ids
  private_route_table_ids    = module.vpc.private_route_table_ids
  endpoint_security_group_id = aws_security_group.endpoints.id

  enable_ssm_endpoints        = true  # ssm + ssmmessages + ec2messages
  enable_ec2_instance_connect = true  # EIC Endpoint para SSH sem internet
  enable_ecr_endpoints        = false # sem BIA container neste desafio
  enable_s3_gateway           = true  # gratuito, para dnf install

  tags = local.common_tags
}

# ─── EC2 Instance ─────────────────────────────────────────────────────────────

resource "aws_instance" "main" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  iam_instance_profile        = aws_iam_instance_profile.ssm.name
  associate_public_ip_address = false

  user_data = <<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y python3
    python3 -m http.server 8080 &
  EOF

  tags = merge(local.common_tags, { Name = "bia-ec2-06" })
}
