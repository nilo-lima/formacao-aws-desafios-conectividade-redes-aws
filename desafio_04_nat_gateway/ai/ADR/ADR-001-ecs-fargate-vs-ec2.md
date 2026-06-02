# ADR-001: ECS Fargate vs EC2 Launch Type

## Status
Aceita

## Contexto
O desafio exige rodar a BIA num cluster ECS em subnet privada. O modulo disponivel em
`shared/modules/ecs-fargate` usa Fargate. O desafio 02 usou EC2 launch type com ASG,
mas o objetivo pedagogico deste desafio e o NAT Gateway (fluxo de saida), nao a gestao
de instancias EC2.

## Decisao
Usar **ECS Fargate** com `assign_public_ip = false` em subnets privadas.

Para que os containers iniciem, o Fargate precisa:
1. Puxar a imagem Docker do ECR (`docker pull`)
2. Comunicar com a API do ECS control plane
3. Enviar logs para o CloudWatch

Sem NAT Gateway (nem VPC Endpoints), essas tres operacoes falham. Isso torna o
comportamento identico ao EC2 em subnet privada: sem NAT nao ha saida, o servico nao
sobe. O aprendizado do fluxo de registro e dependencia do NAT e o mesmo.

## Consequencias
- Positivas: sem EC2 para gerenciar (ASG, capacity provider, user_data), arquitetura
  mais simples, foco 100% no NAT Gateway.
- Negativas: nao demonstra o "registro de instancia EC2 no cluster" literalmente,
  mas demonstra o fluxo equivalente (Fargate task pulling via NAT).
- Riscos: imagem `henrylle/bia` precisa estar no ECR ou ser publica no Docker Hub;
  se privada no ECR, o endpoint de ECR tambem precisa ser acessivel via NAT.
