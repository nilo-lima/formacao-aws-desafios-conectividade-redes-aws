# ADR-003: RDS criado diretamente, sem modulo bia-baseline

## Status
Aceita

## Contexto
O modulo `shared/modules/bia-baseline` provisiona EC2 + RDS juntos. Ele tem flags
`create_ec2 = false` e `create_rds = false`, mas mesmo com `create_ec2 = false` o
modulo cria security groups orientados a "bia-dev" e "bia-web" (nao a ECS tasks),
e exige `subnet_id` para EC2 mesmo quando a EC2 nao e criada.

Para este desafio, o acesso e via ECS Fargate + ALB, nao via EC2. O SG do banco deve
referenciar o SG do ECS task, nao o SG "bia-web" do baseline.

## Decisao
Criar o **RDS e os Security Groups diretamente no `main.tf`** do desafio:
- `aws_security_group` para ALB, ECS tasks e RDS (com regras precisas de source SG)
- `aws_db_subnet_group` apontando para as subnets privadas
- `aws_db_instance` PostgreSQL `db.t3.micro`

## Consequencias
- Positivas: SGs com naming correto para ECS; subnet group privado configurado
  explicitamente; arquitetura legivel sem depender da logica interna do baseline.
- Negativas: ~30 linhas extras de HCL vs reusar o modulo.
- Riscos: senha do RDS via `TF_VAR_rds_password` (nunca hardcoded); variavel marcada
  como `sensitive = true`.
