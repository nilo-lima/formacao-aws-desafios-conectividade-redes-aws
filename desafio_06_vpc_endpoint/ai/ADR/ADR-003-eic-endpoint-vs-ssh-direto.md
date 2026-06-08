# ADR-003: EC2 Instance Connect Endpoint vs SSH direto com chave

## Status
Aceita

## Contexto
SSH direto (porta 22 via internet) exige IP publico na instancia ou VPN/bastion. O EC2 Instance
Connect Endpoint (EIC Endpoint) e um recurso regional da AWS que permite SSH para instancias em
subnet privada sem IP publico, sem VPN e sem bastion, usando o plano de controle da AWS como tunel.

## Decisao
Usar `aws_ec2_instance_connect_endpoint` via modulo shared/modules/vpc-endpoints com
`enable_ec2_instance_connect = true`.

O acesso e feito via: `aws ec2-instance-connect ssh --instance-id <id>`
A AWS CLI gera um certificado de curta duracao (60s) e abre um tunel SSH pelo endpoint.

Diferencas em relacao ao SSH classico:
- Sem exposicao da porta 22 ao internet (0.0.0.0/0)
- Autenticacao via IAM (nao apenas chave SSH)
- Sem necessidade de copiar ou gerenciar chaves privadas

## Consequencias
- Positivas: acesso SSH sem IP publico, sem bastion, sem VPN.
- Positivas: autorizacao controlada por IAM policy.
- Negativas: requer AWS CLI v2 + permissao `ec2-instance-connect:OpenTunnel`.
- Riscos: EIC Endpoint tem custo de ~$0.01/hora mesmo quando ocioso.
