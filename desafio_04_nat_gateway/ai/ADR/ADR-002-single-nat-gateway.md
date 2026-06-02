# ADR-002: Single NAT Gateway vs Um por AZ

## Status
Aceita

## Contexto
O modulo `shared/modules/nat-gateway` suporta `single_nat = true` (1 NAT em 1 AZ) ou
`single_nat = false` (1 NAT por AZ para alta disponibilidade). Com 2 AZs, o modo HA
cria 2 NAT Gateways e 2 EIPs.

## Decisao
Usar **`single_nat = true`** (1 NAT Gateway em us-east-1a).

Custo: 1 NAT GW = $0.045/hr vs 2 NAT GWs = $0.090/hr. Para um lab de ~3h, isso
representa $0.135 vs $0.270. Budget do desafio e $5.

Em producao com SLA, o correto seria 1 NAT por AZ para evitar que uma falha de AZ
derrube toda a saida de internet. Em lab, o risco e aceitavel.

## Consequencias
- Positivas: custo pela metade, configuracao mais simples para fins didaticos.
- Negativas: se us-east-1a falhar, tasks em us-east-1b perdem saida de internet.
- Riscos: baixos em lab; deve ser documentado no README como desvio consciente.
