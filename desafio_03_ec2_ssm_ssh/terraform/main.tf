# ═══════════════════════════════════════════════════════════════════════════════
# main.tf — Desafio 03: EC2 + SSH + SSM + Instance Connect
# Ambiente consolidado que cobre todos os 5 metodos de conectividade:
#   1. SSH direto (bastion publico)
#   2. Bastion Host + SSH Tunnel (EC2 Linux/Windows + RDS privados)
#   3. EC2 Instance Connect (browser/CLI, chave temporaria 60s)
#   4. SSM Session Manager (sem porta aberta, sem IP publico)
#   5. EC2 Instance Connect Endpoint (SSH/RDP a instancias privadas sem bastion)
# ═══════════════════════════════════════════════════════════════════════════════

# ─── 1. VPC ──────────────────────────────────────────────────────────────────
# 2 subnets publicas (bastion + NAT GW) + 2 privadas (EC2 workloads + RDS)
module "vpc" {
  source = "../../shared/modules/vpc"

  name            = "bia-vpc-03"
  cidr_block      = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]

  tags = local.common_tags
}

# ─── 2. NAT Gateway ──────────────────────────────────────────────────────────
# single_nat = true: 1 NAT GW em us-east-1a compartilhado pelas 2 subnets privadas.
# Motivo: custo de lab. Em producao use 1 NAT GW por AZ para resiliencia.
# O SSM Agent das instancias privadas usa este NAT para acessar os endpoints publicos da AWS.
module "nat" {
  source = "../../shared/modules/nat-gateway"

  name_prefix             = "bia-03"
  public_subnet_ids       = module.vpc.public_subnet_ids
  private_route_table_ids = module.vpc.private_route_table_ids
  single_nat              = true
  tags                    = local.common_tags
}

# ─── 3. Key Pair ─────────────────────────────────────────────────────────────
# Importa a chave publica gerada localmente. A chave PRIVADA fica apenas na sua maquina.
# Usada em: bastion (SSH direto) e EC2 privadas (via tunnel ou ICE Endpoint).
# A EC2 Windows usa a chave para descriptografar a senha inicial do Administrator.
resource "aws_key_pair" "lab" {
  key_name   = "bia-lab-03"
  public_key = file(var.public_key_path)

  tags = merge(local.common_tags, { Name = "bia-lab-03" })
}

# Windows AMIs nao suportam Ed25519 — exige RSA separado.
# A chave RSA tambem e necessaria para descriptografar a senha inicial do Administrator.
resource "aws_key_pair" "windows_lab" {
  key_name   = "bia-lab-03-win"
  public_key = file(var.windows_public_key_path)

  tags = merge(local.common_tags, { Name = "bia-lab-03-win" })
}

# ─── 4. IAM: Instance Profile para SSM ───────────────────────────────────────
# AmazonSSMManagedInstanceCore concede permissao para:
#   - ssm:UpdateInstanceInformation (registro do agente)
#   - ssmmessages:* (canal de comunicacao Session Manager)
#   - ec2messages:* (canal de comunicacao Run Command)
# Sem esse perfil, o SSM Agent nao consegue registrar a instancia.
resource "aws_iam_role" "ssm" {
  name = "bia-ssm-role-03"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(local.common_tags, { Name = "bia-ssm-role-03" })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm" {
  name = "bia-ssm-profile-03"
  role = aws_iam_role.ssm.name

  tags = merge(local.common_tags, { Name = "bia-ssm-profile-03" })
}

# ─── 5. Security Groups ───────────────────────────────────────────────────────
#
# IMPORTANTE: ec2_private e ice_endpoint se referenciam mutuamente nas regras.
# Para evitar dependencia circular no Terraform, criamos os 4 SGs sem regras inline
# e adicionamos TODAS as regras via aws_security_group_rule (recursos separados).
# O Terraform cria os SGs primeiro (sem regras), depois adiciona as regras cruzadas.

resource "aws_security_group" "bastion" {
  name        = "bia-03-sg-bastion"
  description = "Bastion Host - acesso SSH administrativo"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, { Name = "bia-03-sg-bastion" })
}

resource "aws_security_group" "ec2_private" {
  name        = "bia-03-sg-ec2-private"
  description = "EC2 privadas - SSH e RDP via bastion e ICE Endpoint"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, { Name = "bia-03-sg-ec2-private" })
}

resource "aws_security_group" "ice_endpoint" {
  name        = "bia-03-sg-ice-endpoint"
  description = "EC2 Instance Connect Endpoint - egress para instancias privadas"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, { Name = "bia-03-sg-ice-endpoint" })
}

resource "aws_security_group" "rds" {
  name        = "bia-03-sg-rds"
  description = "RDS PostgreSQL - acesso via bastion e EC2 privada"
  vpc_id      = module.vpc.vpc_id

  tags = merge(local.common_tags, { Name = "bia-03-sg-rds" })
}

# ── Regras: Bastion ────────────────────────────────────────────────────────────
resource "aws_security_group_rule" "bastion_ingress_ssh" {
  type              = "ingress"
  description       = "SSH administrativo"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.admin_cidr]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion.id
}

# ── Regras: EC2 Privada ────────────────────────────────────────────────────────
resource "aws_security_group_rule" "ec2_ingress_ssh_bastion" {
  type                     = "ingress"
  description              = "SSH via bastion"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.ec2_private.id
}

resource "aws_security_group_rule" "ec2_ingress_rdp_bastion" {
  type                     = "ingress"
  description              = "RDP via bastion tunnel"
  from_port                = 3389
  to_port                  = 3389
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.ec2_private.id
}

resource "aws_security_group_rule" "ec2_ingress_ssh_ice" {
  type                     = "ingress"
  description              = "SSH via ICE Endpoint"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ice_endpoint.id
  security_group_id        = aws_security_group.ec2_private.id
}

resource "aws_security_group_rule" "ec2_ingress_rdp_ice" {
  type                     = "ingress"
  description              = "RDP via ICE Endpoint"
  from_port                = 3389
  to_port                  = 3389
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ice_endpoint.id
  security_group_id        = aws_security_group.ec2_private.id
}

resource "aws_security_group_rule" "ec2_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_private.id
}

# ── Regras: ICE Endpoint ───────────────────────────────────────────────────────
# O ICE Endpoint atua como "proxy" de saida para SSH/RDP.
# Sua SG controla o EGRESS (para quais instancias ele pode se conectar).
# A SG das instancias controla o INGRESS (de qual SG ela aceita conexoes).
resource "aws_security_group_rule" "ice_egress_ssh" {
  type                     = "egress"
  description              = "SSH para instancias privadas"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_private.id
  security_group_id        = aws_security_group.ice_endpoint.id
}

resource "aws_security_group_rule" "ice_egress_rdp" {
  type                     = "egress"
  description              = "RDP para instancias privadas"
  from_port                = 3389
  to_port                  = 3389
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_private.id
  security_group_id        = aws_security_group.ice_endpoint.id
}

# ── Regras: RDS ───────────────────────────────────────────────────────────────
resource "aws_security_group_rule" "rds_ingress_bastion" {
  type                     = "ingress"
  description              = "PostgreSQL via bastion (tunnel SSH)"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = aws_security_group.rds.id
}

resource "aws_security_group_rule" "rds_ingress_ec2" {
  type                     = "ingress"
  description              = "PostgreSQL via EC2 privada"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2_private.id
  security_group_id        = aws_security_group.rds.id
}

# ─── 6. Data Sources: AMIs ───────────────────────────────────────────────────
# Sempre busca a AMI mais recente do owner "amazon" — evita fixar IDs que mudam por regiao.
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "windows_2022" {
  count       = var.enable_windows ? 1 : 0
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ─── 7. EC2: Bastion Host ────────────────────────────────────────────────────
# Unico recurso com IP publico. Serve como:
#   - Ponto de entrada SSH para as instancias privadas (tunnel)
#   - Demonstracao de EC2 Instance Connect via browser/CLI (Aula 03)
#   - Jump host para SSM Port Forwarding como host intermediario
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  key_name                    = aws_key_pair.lab.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ssm.name

  tags = merge(local.common_tags, { Name = "bia-03-bastion" })
}

# ─── 8. EC2: Linux Privada ───────────────────────────────────────────────────
# Sem IP publico, sem porta aberta para internet.
# Acessivel por: tunnel SSH via bastion | SSM Session Manager | ICE Endpoint.
resource "aws_instance" "ec2_linux" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.ec2_private.id]
  key_name               = aws_key_pair.lab.key_name
  iam_instance_profile   = aws_iam_instance_profile.ssm.name

  tags = merge(local.common_tags, { Name = "bia-03-ec2-linux-private" })
}

# ─── 9. EC2: Windows Privada (opcional via enable_windows) ───────────────────
# count = 1 quando enable_windows = true, 0 caso contrario.
# Acesso RDP: via tunnel SSH (porta local 3389) ou via ICE Endpoint.
# Senha inicial: descriptografada com a chave privada no console AWS.
resource "aws_instance" "ec2_windows" {
  count = var.enable_windows ? 1 : 0

  ami                    = data.aws_ami.windows_2022[0].id
  instance_type          = "t3.micro"
  subnet_id              = module.vpc.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.ec2_private.id]
  key_name               = aws_key_pair.windows_lab.key_name
  iam_instance_profile   = aws_iam_instance_profile.ssm.name

  tags = merge(local.common_tags, { Name = "bia-03-ec2-windows-private" })
}

# ─── 10. RDS: PostgreSQL 15 ──────────────────────────────────────────────────
# DB Subnet Group exige subnets em pelo menos 2 AZs (requisito do servico gerenciado).
# A instancia RDS em si fica na AZ da primeira subnet privada.
# Acesso: apenas via tunnel SSH (bastion) ou SSM Port Forwarding (ec2_linux como intermediario).
resource "aws_db_subnet_group" "this" {
  name       = "bia-03-db-subnet-group"
  subnet_ids = module.vpc.private_subnet_ids

  tags = merge(local.common_tags, { Name = "bia-03-db-subnet-group" })
}

resource "aws_db_instance" "postgres" {
  identifier        = "bia-03-postgres"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "labdb"
  username = "postgres"
  password = var.rds_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible     = false
  skip_final_snapshot     = true
  deletion_protection     = false
  backup_retention_period = 0

  tags = merge(local.common_tags, { Name = "bia-03-postgres" })
}

# ─── 11. EC2 Instance Connect Endpoint ───────────────────────────────────────
# O ICE Endpoint e um recurso de VPC (nao por subnet): 1 endpoint cobre toda a VPC.
# preserve_client_ip = true: a instancia alvo ve o IP real do cliente (auditoria).
# Diferenca do bastion: nao ha instancia EC2 rodando — e um servico gerenciado pela AWS.
# Custo: ~$0.01/h pelo endpoint + $0.01/GB de dados processados.
resource "aws_ec2_instance_connect_endpoint" "this" {
  subnet_id          = module.vpc.private_subnet_ids[0]
  security_group_ids = [aws_security_group.ice_endpoint.id]
  preserve_client_ip = true

  tags = merge(local.common_tags, { Name = "bia-03-ice-endpoint" })
}
