# ADR-002: SSM Session Manager vs Bastion Host para acesso a instancias privadas

## Status
Aceita

## Contexto
Instancias em subnet privada sem IP publico precisam de um mecanismo de acesso para gerenciamento.
A abordagem classica e um Bastion Host (jump server) em subnet publica. O SSM Session Manager
com VPC Interface Endpoints e a alternativa moderna sem necessidade de EC2 extra nem porta 22 exposta.

## Decisao
Usar SSM Session Manager via VPC Interface Endpoints (ssm + ssmmessages + ec2messages).

| Criterio | Bastion Host | SSM Session Manager |
|---|---|---|
| EC2 extra | Sim (~$8/mes t3.micro) | Nao |
| Porta 22 exposta | Sim (para bastion) | Nao |
| IAM auditoria | Nao nativo | Sim (CloudTrail) |
| Custo endpoints | $0 | ~$0.03/hora (3 endpoints) |
| Sessao sem agente | Sim | Nao (SSM agent obrigatorio) |

Para sessoes de lab curtas, 3 endpoints Interface custam $0.06 por 2h vs $0.016 de uma EC2 bastion.
O custo e equivalente, mas SSM elimina uma superficie de ataque inteira.

## Consequencias
- Positivas: sem EC2 bastion, sem gerenciamento de chave SSH exposta ao internet.
- Positivas: sessoes auditadas via CloudTrail e SSM Session Manager logs.
- Negativas: requer SSM agent (pre-instalado no Amazon Linux 2023).
- Riscos: se os 3 endpoints nao estiverem funcionais, nenhum acesso SSM e possivel.
