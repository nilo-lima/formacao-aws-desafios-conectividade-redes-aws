# ADR-002: CIDRs não sobrepostos por design (10.N.0.0/16)

## Status
Aceita

## Contexto
VPC Peering tem uma restrição fundamental: os blocos CIDR das VPCs participantes não podem
se sobrepor. Qualquer sobreposição impede a criação do peering e resulta em erro da API AWS.

## Decisão
Adotar o padrão `10.N.0.0/16` onde N é o número do desafio:

| VPC | Região | CIDR | Subnet pública |
|-----|--------|------|----------------|
| bia-vpc-05-east1 | us-east-1 | 10.0.0.0/16 | 10.0.1.0/24 |
| bia-vpc-05-east2 | us-east-2 | 10.1.0.0/16 | 10.1.1.0/24 |

O /16 oferece 65 536 endereços por VPC - sobra para subnetear nos desafios futuros.
O desafio 06 (VPC Endpoints) fica reservado para 10.2.0.0/16 caso precise de peering.

## Consequências
- Positivas: sem risco de overlap agora ou em desafios futuros do mês.
- Positivas: CIDRs fáceis de memorizar e depurar (10.0.x = east-1, 10.1.x = east-2).
- Negativas: nenhuma relevante para o escopo de lab.
