# ═══════════════════════════════════════════════════════════════════════════════
# Desafio 05 — VPC Peering Multi-Regiao (us-east-1 <-> us-east-2)
# ═══════════════════════════════════════════════════════════════════════════════

# ─── AMIs Amazon Linux 2023 ─────────────────────────────────────────────────

data "aws_ami" "al2023_east1" {
  provider    = aws.useast1
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

data "aws_ami" "al2023_east2" {
  provider    = aws.useast2
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ─── VPCs ───────────────────────────────────────────────────────────────────

module "vpc_east1" {
  source = "../../shared/modules/vpc"
  providers = {
    aws = aws.useast1
  }

  name           = "bia-vpc-05-east1"
  cidr_block     = var.vpc_cidr_east1
  azs            = [var.az_east1]
  public_subnets = [var.subnet_public_east1]
  tags           = local.common_tags
}

module "vpc_east2" {
  source = "../../shared/modules/vpc"
  providers = {
    aws = aws.useast2
  }

  name           = "bia-vpc-05-east2"
  cidr_block     = var.vpc_cidr_east2
  azs            = [var.az_east2]
  public_subnets = [var.subnet_public_east2]
  tags           = local.common_tags
}

# ─── Observability ──────────────────────────────────────────────────────────

module "obs_east1" {
  source = "../../shared/modules/observability"
  providers = {
    aws = aws.useast1
  }

  name_prefix    = "bia-05-east1"
  log_groups     = ["/bia/desafio-05/east1/ec2"]
  retention_days = 7
  tags           = local.common_tags
}

module "obs_east2" {
  source = "../../shared/modules/observability"
  providers = {
    aws = aws.useast2
  }

  name_prefix    = "bia-05-east2"
  log_groups     = ["/bia/desafio-05/east2/ec2"]
  retention_days = 7
  tags           = local.common_tags
}

# ─── Security Groups ────────────────────────────────────────────────────────

resource "aws_security_group" "ec2_east1" {
  provider    = aws.useast1
  name        = "bia-sg-05-east1"
  description = "EC2 east1: ICMP+SSH via peering de east2, SSH admin externo"
  vpc_id      = module.vpc_east1.vpc_id

  ingress {
    description = "ICMP from VPC-B (peering)"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr_east2]
  }

  ingress {
    description = "SSH from VPC-B (peering)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_east2]
  }

  ingress {
    description = "SSH admin externo"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "bia-sg-05-east1" })
}

resource "aws_security_group" "ec2_east2" {
  provider    = aws.useast2
  name        = "bia-sg-05-east2"
  description = "EC2 east2: ICMP+SSH via peering de east1, SSH admin externo"
  vpc_id      = module.vpc_east2.vpc_id

  ingress {
    description = "ICMP from VPC-A (peering)"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [var.vpc_cidr_east1]
  }

  ingress {
    description = "SSH from VPC-A (peering)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_east1]
  }

  ingress {
    description = "SSH admin externo"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "bia-sg-05-east2" })
}

# ─── Key Pairs ──────────────────────────────────────────────────────────────

resource "aws_key_pair" "east1" {
  provider   = aws.useast1
  key_name   = "bia-key-05-east1"
  public_key = var.public_key
  tags       = merge(local.common_tags, { Name = "bia-key-05-east1" })
}

resource "aws_key_pair" "east2" {
  provider   = aws.useast2
  key_name   = "bia-key-05-east2"
  public_key = var.public_key
  tags       = merge(local.common_tags, { Name = "bia-key-05-east2" })
}

# ─── EC2 Instances ──────────────────────────────────────────────────────────

resource "aws_instance" "east1" {
  provider                    = aws.useast1
  ami                         = data.aws_ami.al2023_east1.id
  instance_type               = var.instance_type
  subnet_id                   = module.vpc_east1.public_subnet_ids[0]
  key_name                    = aws_key_pair.east1.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_east1.id]
  associate_public_ip_address = true

  tags = merge(local.common_tags, { Name = "bia-ec2-05-east1" })
}

resource "aws_instance" "east2" {
  provider                    = aws.useast2
  ami                         = data.aws_ami.al2023_east2.id
  instance_type               = var.instance_type
  subnet_id                   = module.vpc_east2.public_subnet_ids[0]
  key_name                    = aws_key_pair.east2.key_name
  vpc_security_group_ids      = [aws_security_group.ec2_east2.id]
  associate_public_ip_address = true

  tags = merge(local.common_tags, { Name = "bia-ec2-05-east2" })
}

# ─── VPC Peering ────────────────────────────────────────────────────────────

resource "aws_vpc_peering_connection" "east1_to_east2" {
  provider    = aws.useast1
  vpc_id      = module.vpc_east1.vpc_id
  peer_vpc_id = module.vpc_east2.vpc_id
  peer_region = "us-east-2"

  tags = merge(local.common_tags, { Name = "bia-pcx-05-east1-to-east2" })
}

# auto_accept = true funciona para contas identicas; o provider useast2 aceita o pedido via API
resource "aws_vpc_peering_connection_accepter" "east2" {
  provider                  = aws.useast2
  vpc_peering_connection_id = aws_vpc_peering_connection.east1_to_east2.id
  auto_accept               = true

  tags = merge(local.common_tags, { Name = "bia-pcx-05-accepter-east2" })
}

# ─── Rotas de Peering ───────────────────────────────────────────────────────

resource "aws_route" "east1_to_east2" {
  provider                  = aws.useast1
  route_table_id            = module.vpc_east1.public_route_table_id
  destination_cidr_block    = var.vpc_cidr_east2
  vpc_peering_connection_id = aws_vpc_peering_connection.east1_to_east2.id

  depends_on = [aws_vpc_peering_connection_accepter.east2]
}

resource "aws_route" "east2_to_east1" {
  provider                  = aws.useast2
  route_table_id            = module.vpc_east2.public_route_table_id
  destination_cidr_block    = var.vpc_cidr_east1
  vpc_peering_connection_id = aws_vpc_peering_connection.east1_to_east2.id

  depends_on = [aws_vpc_peering_connection_accepter.east2]
}
