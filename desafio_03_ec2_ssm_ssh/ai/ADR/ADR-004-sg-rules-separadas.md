# ADR-004: Regras de SG via aws_security_group_rule (nao inline)

## Status
Aceita

## Contexto
Os security groups `sg-ec2-private` e `sg-ice-endpoint` se referenciam mutuamente: ec2-private permite ingress de ice-endpoint, e ice-endpoint tem egress para ec2-private. Se as regras forem definidas inline dentro do `aws_security_group`, o Terraform nao consegue resolver a ordem de criacao e retorna erro de dependencia circular.

## Decisao
Criar os quatro security groups sem regras inline e adicionar todas as regras via recursos `aws_security_group_rule` separados. O Terraform cria os SGs primeiro (vazios) e depois aplica as regras.

## Consequencias
- Positivas: elimina dependencia circular; o codigo e mais explicito sobre cada regra individualmente.
- Negativas: mais recursos no state (~13 `aws_security_group_rule` vs 4 blocos inline); nao misturar inline com `aws_security_group_rule` no mesmo SG (causaria conflito de gerenciamento).
- Riscos: nenhum em ambiente de lab.
