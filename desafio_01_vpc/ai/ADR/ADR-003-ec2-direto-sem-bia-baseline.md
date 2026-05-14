# ADR-003 — EC2 bia-dev criada diretamente em main.tf (sem módulo bia-baseline)

- **Status:** Aceito
- **Data:** 2026-05-13
- **Desafio:** 01 — VPC + Subnet Pública

## Contexto

O módulo `shared/modules/bia-baseline` cria em conjunto: EC2, RDS, IAM role/profile e
Security Groups. Para este desafio:
1. IAM (`role-acesso-ssm`) já existe na conta → criação via módulo causaria conflito.
2. RDS está fora de escopo (PRD seção 5).
3. O módulo não expõe variável `key_name` para o par de chaves `test-key`.
4. O `user_data` do módulo é genérico; o PRD exige script adaptado (`user_data_ec2_zona_a.sh`).

## Decisão

Criar `aws_instance "bia_dev"` diretamente no `main.tf` do desafio, com:
- `key_name = "test-key"`
- `iam_instance_profile = data.aws_iam_instance_profile.ssm.name`
- `user_data = file("../scripts/user_data_ec2_zona_a.sh")`
- `vpc_security_group_ids = [aws_security_group.bia_dev.id]`

## Consequências

- Controle total sobre a configuração da instância sem adaptar o módulo compartilhado.
- O módulo `bia-baseline` permanece intacto para desafios futuros que precisem criar IAM do zero.
- Pequena duplicação de definição de SG (também no módulo) — aceitável para este escopo.
