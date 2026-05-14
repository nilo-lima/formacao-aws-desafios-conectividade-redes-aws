# ADR-001 — Usar shared/modules/vpc para toda a camada de rede

- **Status:** Aceito
- **Data:** 2026-05-13
- **Desafio:** 01 — VPC + Subnet Pública

## Contexto

O PRD requer VPC customizada com 2 subnets públicas, IGW e route table associadas às subnets.
O monorepo possui o módulo `shared/modules/vpc` que encapsula exatamente esses recursos.

## Decisão

Usar `shared/modules/vpc` passando:
- `name = "desafio-01"` (conforme auto-generate do PRD)
- `cidr_block = "10.0.0.0/16"`
- `public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]`
- `azs = ["us-east-1a", "us-east-1b"]`
- `private_subnets = []` (sem subnets privadas neste desafio)
- `tags = local.common_tags`

## Consequências

- Reutilização imediata do módulo testado.
- Consistência de naming e tags entre todos os desafios.
- Subnets privadas ficam desabilitadas (`private_subnets = []`), sem custo de NAT Gateway.
