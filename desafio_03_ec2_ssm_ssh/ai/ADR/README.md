# ADRs - Desafio 03: EC2 + SSH + SSM + Instance Connect

Registro das decisoes arquiteturais tomadas durante o design e implementacao do desafio.

| ADR | Titulo | Status |
|---|---|---|
| [ADR-001](ADR-001-ambiente-unico-consolidado.md) | Ambiente unico consolidado para todos os metodos | Aceita |
| [ADR-002](ADR-002-windows-key-pair-rsa.md) | Key pair RSA separado para Windows | Aceita |
| [ADR-003](ADR-003-ssm-via-nat-gateway.md) | SSM via NAT Gateway (nao VPC Endpoints) | Aceita |
| [ADR-004](ADR-004-sg-rules-separadas.md) | Regras de SG via aws_security_group_rule | Aceita |
