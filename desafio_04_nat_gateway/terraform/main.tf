# ═══════════════════════════════════════════════════════════════════════════════
# Desafio 04 — NAT Gateway + ECS Privado
# BIA rodando em subnet privada; saida de internet exclusivamente via NAT GW.
# ═══════════════════════════════════════════════════════════════════════════════

# ─── ECR ─────────────────────────────────────────────────────────────────────

resource "aws_ecr_repository" "bia" {
  name                 = "bia"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.common_tags, { Name = "bia" })
}

# ─── VPC ─────────────────────────────────────────────────────────────────────

module "vpc" {
  source = "../../shared/modules/vpc"

  name            = "${local.name_prefix}-vpc"
  azs             = ["${var.region}a", "${var.region}b"]
  cidr_block      = "10.4.0.0/16"
  public_subnets  = ["10.4.1.0/24", "10.4.2.0/24"]
  private_subnets = ["10.4.10.0/24", "10.4.20.0/24"]
  tags            = local.common_tags
}

# ─── NAT Gateway ─────────────────────────────────────────────────────────────
# Ponto central do desafio: sem este recurso as tasks Fargate nao sobem.
# single_nat=true: 1 NAT em us-east-1a (lab - ver ADR-002).

module "nat_gw" {
  source = "../../shared/modules/nat-gateway"

  name_prefix             = local.name_prefix
  public_subnet_ids       = module.vpc.public_subnet_ids
  private_route_table_ids = module.vpc.private_route_table_ids
  single_nat              = true
  tags                    = local.common_tags
}

# ─── Security Groups ─────────────────────────────────────────────────────────

resource "aws_security_group" "alb" {
  name        = "${local.name_prefix}-alb"
  description = "ALB bia-04 - inbound HTTP 80"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP publico"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-alb" })
}

resource "aws_security_group" "ecs" {
  name        = "${local.name_prefix}-ecs"
  description = "ECS Fargate bia-04 - inbound do ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "BIA porta 8080 somente do ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Saida irrestrita - NAT GW roteia para ECR e ECS API"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-ecs" })
}

resource "aws_security_group" "rds" {
  name        = "${local.name_prefix}-rds"
  description = "RDS bia-04 - inbound Postgres somente das tasks ECS"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.name_prefix}-rds" })
}

resource "aws_security_group_rule" "rds_from_ecs" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  description              = "Postgres desde tasks ECS"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_security_group.ecs.id
}

# ─── ALB ─────────────────────────────────────────────────────────────────────

module "alb" {
  source = "../../shared/modules/alb"

  name_prefix        = local.name_prefix
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  security_group_ids = [aws_security_group.alb.id]
  target_port        = 8080
  health_check_path  = "/"
  tags               = local.common_tags
}

# ─── ECS Fargate ─────────────────────────────────────────────────────────────
# assign_public_ip=false: tasks sem IP publico, saida EXCLUSIVAMENTE via NAT GW.
# depends_on garante que NAT GW e rotas estejam prontos antes das tasks subirem.

module "ecs" {
  source = "../../shared/modules/ecs-fargate"

  name_prefix        = local.name_prefix
  cluster_name       = "${local.name_prefix}-cluster"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.ecs.id]
  container_image    = "${aws_ecr_repository.bia.repository_url}:latest"
  container_port     = 8080
  desired_count      = 1
  cpu                = 256
  memory             = 512
  assign_public_ip   = false
  target_group_arn   = module.alb.target_group_arn

  # DB_PWD em plaintext e aceitavel em lab. Em producao: usar Secrets Manager.
  environment_variables = [
    { name = "DB_HOST", value = aws_db_instance.bia.address },
    { name = "DB_PORT", value = "5432" },
    { name = "DB_NAME", value = "bia" },
    { name = "DB_USER", value = "postgres" },
    { name = "DB_PWD", value = var.rds_password },
  ]

  tags = local.common_tags

  depends_on = [module.nat_gw]
}

# ─── RDS PostgreSQL ───────────────────────────────────────────────────────────

resource "aws_db_subnet_group" "bia" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = module.vpc.private_subnet_ids
  tags       = merge(local.common_tags, { Name = "${local.name_prefix}-db-subnet-group" })
}

resource "aws_db_instance" "bia" {
  identifier        = local.name_prefix
  engine            = "postgres"
  engine_version    = "17.4"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "bia"
  username = "postgres"
  password = var.rds_password

  db_subnet_group_name   = aws_db_subnet_group.bia.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible     = false
  multi_az                = false
  backup_retention_period = 0
  skip_final_snapshot     = true
  deletion_protection     = false

  tags = merge(local.common_tags, { Name = local.name_prefix })
}
