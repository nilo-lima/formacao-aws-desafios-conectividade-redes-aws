# ADR-004: S3 Gateway Endpoint gratuito para atualizacoes de pacotes

## Status
Aceita

## Contexto
O Amazon Linux 2023 busca pacotes via dnf/yum de repositorios hospedados no Amazon S3
(https://cdn.amazonlinux.com e mirrors regionais no S3). Sem acesso ao S3, `dnf install`
falha mesmo que o S3 seja o unico destino necessario.

Um NAT Gateway resolveria isso mas custa $0.045/hora. O S3 Gateway Endpoint e gratuito
(sem custo de hora nem de dados), resolve o mesmo problema e e a solucao idiomatica da AWS.

## Decisao
Habilitar `enable_s3_gateway = true` no modulo vpc-endpoints. O endpoint Gateway e associado
a route table privada via `private_route_table_ids`. Pacotes dnf resolvem o FQDN do S3 para
um IP prefixado, que e roteado pelo endpoint ao inves de sair para internet.

Diferenca Gateway vs Interface:
- **Gateway**: sem ENI, sem SG, sem custo — apenas uma entrada na route table.
- **Interface**: tem ENI na subnet, tem SG, custa ~$0.01/hora.

S3 e DynamoDB sao os unicos servicos que suportam o tipo Gateway.

## Consequencias
- Positivas: `dnf install python3 curl` funciona sem NAT e sem custo adicional.
- Positivas: transferencia de dados S3 via Gateway nao tem custo de Data Transfer Out.
- Negativas: nenhuma — recurso gratuito sem contrapartida.
