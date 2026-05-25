# ADR-003: SSM via NAT Gateway (nao VPC Endpoints)

## Status
Aceita

## Contexto
O SSM Agent em instancias em subnet privada precisa de conectividade de saida para os endpoints publicos da AWS (ssm, ssmmessages, ec2messages). Isso pode ser resolvido com NAT Gateway ou com VPC Endpoints privados.

## Decisao
Usar o NAT Gateway (ja necessario no ambiente) para o SSM Agent estabelecer comunicacao de saida. Nao criar VPC Endpoints para SSM neste desafio.

## Consequencias
- Positivas: NAT Gateway ja existe no ambiente; sem custo adicional de endpoints; configuracao mais simples.
- Negativas: o SSM Agent gera trafego de saida pelo NAT (custo de data transfer ~$0,09/GB); instancias dependem de conectividade internet para SSM.
- Riscos: em ambientes sem internet, o SSM nao funcionaria sem VPC Endpoints. VPC Endpoints sao o tema especifico do Desafio 06.
