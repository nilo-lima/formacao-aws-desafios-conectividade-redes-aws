# ADR-002 — Recriar SG bia-dev na nova VPC; IAM profile via data source

- **Status:** Aceito
- **Data:** 2026-05-13
- **Desafio:** 01 — VPC + Subnet Pública

## Contexto

O PRD diz "Utilizar o security group existente 'bia-dev'". Porém, Security Groups são
VPC-específicos: um SG criado na VPC default não pode ser associado a uma instância em
outra VPC. O `role-acesso-ssm`, sendo um IAM Instance Profile, é global e pode ser
referenciado diretamente.

## Decisão

- **SG `bia-dev`:** Criar novo recurso `aws_security_group` neste desafio, dentro da VPC
  recém-criada, com as mesmas regras do template `bia-baseline` (portas 80 e 3001 de ingress).
- **IAM Instance Profile `role-acesso-ssm`:** Referenciar via `data "aws_iam_instance_profile"`,
  sem criar novo recurso.
- **Key pair `test-key`:** Referenciar por nome (`key_name = "test-key"`) sem criar novo par.

## Consequências

- SG recriado com regras idênticas, mas vinculado à VPC correta.
- Nenhum conflito com recursos IAM existentes na conta.
- `terraform destroy` remove apenas recursos deste desafio; IAM e key pair pré-existentes
  não são afetados.
