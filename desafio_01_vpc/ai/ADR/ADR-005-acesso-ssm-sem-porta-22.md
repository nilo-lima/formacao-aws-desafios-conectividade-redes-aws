# ADR-005 — Acesso à EC2 via SSM Session Manager (sem porta 22 exposta)

- **Status:** Aceito
- **Data:** 2026-05-13
- **Desafio:** 01 — VPC + Subnet Pública

## Contexto

O PRD lista como Key Result: "Acessar a instância EC2 via SSM". O IAM instance profile
`role-acesso-ssm` já carrega `AmazonSSMManagedInstanceCore`. A EC2 está em subnet pública
com IP público, portanto o SSM Agent consegue alcançar os endpoints da AWS via internet
(sem necessidade de VPC Endpoints neste desafio).

## Decisão

- **Porta 22 não aberta** no SG `bia-dev` (ingress apenas 80 e 3001).
- `key_name = "test-key"` configurado como fallback de emergência (boa prática manter).
- Acesso operacional via `aws ssm start-session --target <instance-id>`.

## Consequências

- Superfície de ataque reduzida (sem SSH público).
- Alinhado ao objetivo de aprendizagem do desafio.
- Em desafios futuros com subnet privada, será necessário adicionar VPC Endpoints SSM
  (módulo `vpc-endpoints`) para que o SSM Agent alcance o serviço sem IGW.
