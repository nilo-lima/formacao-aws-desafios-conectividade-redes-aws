# ADR-003: EC2 em subnet pública (sem NAT Gateway)

## Status
Aceita

## Contexto
O objetivo do desafio é validar comunicação ICMP/SSH cross-region via VPC Peering usando
endereços IP *privados*. As instâncias precisam apenas de:
1. IP privado para comunicação via peering (obrigatório).
2. IP público para acesso de gestão SSH do operador (opcional, mas conveniente).

Adicionar subnets privadas + NAT Gateway custaria ~$0.045/hora por região ($0.09/h total),
elevando o custo do lab de ~$0.06 para ~$0.33 por sessão - 5x mais caro sem benefício técnico.

## Decisão
Instâncias EC2 em subnets públicas com `associate_public_ip_address = true`.
O IGW serve apenas para gestão (SSH do operador). O tráfego de validação (ping/SSH cross-region)
trafega exclusivamente pelo VPC Peering usando IPs privados.

Security Groups restringem SSH externo ao `admin_cidr` informado pelo operador.
SSH via peering é restrito ao CIDR da VPC par (10.0.0.0/16 ou 10.1.0.0/16).

## Consequências
- Positivas: custo ~5x menor; destruir e recriar é rápido.
- Positivas: topologia mais simples, fácil de depurar.
- Negativas: EC2 tem IP público exposto - mitigado pelo SG com admin_cidr restrito.
- Riscos: se admin_cidr = 0.0.0.0/0 SSH fica aberto; documentado no tfvars.example.
