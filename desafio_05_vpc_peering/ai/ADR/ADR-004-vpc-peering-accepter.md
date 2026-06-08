# ADR-004: Aceitação automática do VPC Peering via aws_vpc_peering_connection_accepter

## Status
Aceita

## Contexto
VPC Peering cross-region (mesmo que mesma conta AWS) não suporta `auto_accept = true` diretamente
no recurso `aws_vpc_peering_connection`. O pedido fica em estado `pending-acceptance` até ser
aceito explicitamente pela região do peer.

O Terraform oferece o recurso `aws_vpc_peering_connection_accepter` que, quando configurado com
o provider da região accepter e `auto_accept = true`, aceita o pedido automaticamente via API,
tornando o processo idempotente e sem necessidade de intervenção manual no console.

## Decisão
Usar dois recursos distintos:

```hcl
# Requester - us-east-1
resource "aws_vpc_peering_connection" "east1_to_east2" {
  provider    = aws.useast1
  vpc_id      = module.vpc_east1.vpc_id
  peer_vpc_id = module.vpc_east2.vpc_id
  peer_region = "us-east-2"
}

# Accepter - us-east-2
resource "aws_vpc_peering_connection_accepter" "east2" {
  provider                  = aws.useast2
  vpc_peering_connection_id = aws_vpc_peering_connection.east1_to_east2.id
  auto_accept               = true
}
```

As rotas de peering usam `depends_on = [aws_vpc_peering_connection_accepter.east2]` para garantir
que a conexão esteja no estado `active` antes de adicionar as rotas.

## Consequências
- Positivas: fluxo 100% automatizado; `terraform apply` produz peering ativo em uma execução.
- Positivas: idempotente - segundo `apply` não recria nem rejeita o peering.
- Negativas: nenhuma relevante.
- Riscos: se as credenciais AWS não tiverem permissão em us-east-2, o accepter falhará com
  AccessDenied - verificar policy antes do apply.
