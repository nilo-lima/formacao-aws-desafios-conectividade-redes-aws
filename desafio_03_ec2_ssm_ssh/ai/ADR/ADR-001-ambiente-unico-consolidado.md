# ADR-001: Ambiente unico consolidado para todos os metodos

## Status
Aceita

## Contexto
O curso apresenta os 5 metodos de conectividade em aulas progressivas, cada uma construindo e destruindo um ambiente menor. Para o desafio, e necessario decidir entre replicar essa progressao em workspaces Terraform separados ou consolidar tudo em um unico apply.

## Decisao
Um unico `terraform apply` provisiona o ambiente completo com todos os recursos necessarios para demonstrar os 5 metodos simultaneamente.

## Consequencias
- Positivas: custo concentrado em uma sessao; todos os metodos testados no mesmo ambiente; gerenciamento simplificado; unico `terraform destroy` limpa tudo.
- Negativas: o apply e mais longo (~12 min devido ao RDS e ICE Endpoint); nao replica exatamente o fluxo progressivo das aulas.
- Riscos: se um recurso falhar no apply, os demais ja criados permanecem ativos gerando custo ate o destroy.
