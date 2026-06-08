# ADR-001: VPC somente com subnet privada - sem IGW funcional, sem NAT

## Status
Aceita

## Contexto
O objetivo do desafio e provar que e possivel gerenciar EC2 sem internet de saida. Uma VPC com
subnet publica + NAT Gateway tornaria o desafio identico ao desafio 04. Para evidenciar o valor
dos VPC Endpoints, a instancia nao pode ter rota para internet.

## Decisao
VPC com apenas subnet privada (`private_subnets = ["10.0.2.0/24"]`, `public_subnets = []`).

O modulo shared/modules/vpc cria um IGW e uma route table publica mesmo sem subnets publicas
(recursos nao sao contados/condicionais no modulo). Esses recursos existem mas sao inerts: nenhuma
subnet e associada a RT publica, logo nenhum trafego flui pelo IGW.

A subnet privada tem sua propria route table sem rota 0.0.0.0/0. Trafego de saida so alcanca
endpoints configurados explicitamente (SSM via Interface, S3 via Gateway).

## Consequencias
- Positivas: prova que SSM + EIC Endpoint funcionam 100% sem internet.
- Positivas: sem NAT Gateway = sem $0.045/hora = custo da sessao ~5x menor.
- Negativas: IGW e RT publica sao criados pelo modulo mesmo sem uso (2 recursos extras no state).
- Riscos: sem internet de saida, nao e possivel fazer pull de imagens Docker do Docker Hub.
