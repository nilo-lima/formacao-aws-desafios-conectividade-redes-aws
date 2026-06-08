# ADR-001: Dual-provider Terraform com aliases de região

## Status
Aceita

## Contexto
O desafio exige recursos em duas regiões AWS distintas (us-east-1 e us-east-2) gerenciados por
um único `terraform apply`. O Terraform permite múltiplas configurações do mesmo provider usando
`alias`, e módulos reutilizáveis aceitam provider externo via bloco `providers = { aws = aws.alias }`.

## Decisão
Usar dois blocos `provider "aws"` com aliases `useast1` e `useast2` no root module.
Cada chamada de módulo (`vpc`, `observability`) recebe o provider correto via:

```hcl
module "vpc_east1" {
  source    = "../../shared/modules/vpc"
  providers = { aws = aws.useast1 }
  ...
}
```

Recursos diretos (SG, EC2, peering) recebem `provider = aws.useastN` explicitamente.
Os módulos `shared/` não precisam de alteração - o mapeamento `providers = { aws = aws.alias }`
substitui o provider default do módulo sem exigir `configuration_aliases`.

## Consequências
- Positivas: estado unificado em um único `terraform.tfstate`; `apply` e `destroy` atômicos.
- Positivas: sem necessidade de workspaces ou backends separados por região.
- Negativas: providers.tf usa regiões hardcoded (providers não aceitam variáveis).
- Riscos: `terraform init` baixa o provider duas vezes (um por alias); custo de tempo desprezível.
