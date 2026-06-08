# 📊 Dashboard de Progresso - Mai/2026

> **Mês:** Maio 2026 · **Trilha:** Conectividade e Redes na AWS
> **Carga estimada total:** 4 dias, 13h35m de estudos
> **Mentor:** Henrylle Maia (Formação AWS 5.0)

---

## 🎯 Resumo Visual

| Status | Quantidade | % |
|---|:---:|:---:|
| ✅ Concluído | 6 | 100% |
| 🔵 Em andamento | 0 | 0% |
| 🟡 Aguardando | 0 | 0% |
| ❌ Bloqueado | 0 | 0% |

```
████████████████████  6/6  (100%)
```

---

## 📋 Detalhamento dos Desafios

### ✅ Desafio 01 - VPC + Subnet Pública

- **Pasta:** [`desafio_01_vpc/`](./desafio_01_vpc/)
- **Nível:** ⭐ (1/3)
- **Categoria:** Não linear
- **Data limite do post:** 18/05/2026
- **Carga estudo:** 11h33
- **Objetivo:** Lançar a `bia-dev` em subnet pública customizada, criar VPC manual e visual.
- **Status:** ✅ Concluído (2026-05-13)
- **Custo real:** ~$0.03 (sessão ~2h)
- **Repositório:** [formacao-aws-desafios-conectividade-redes-aws](https://github.com/nilo-lima/formacao-aws-desafios-conectividade-redes-aws)

### ✅ Desafio 02 - VPC + Subnet Pública + ECS

- **Pasta:** [`desafio_02_ecs_publico/`](./desafio_02_ecs_publico/)
- **Nível:** ⭐⭐ (2/3)
- **Categoria:** Não linear
- **Data limite do post:** 25/05/2026
- **Carga estudo:** 1d 3h41
- **Objetivo:** BIA no ECS em VPC customizada com 2 AZs, alta disponibilidade.
- **Status:** ✅ Concluído (2026-05-15)
- **Custo real:** ~$0.23 (sessão ~3h)
- **Recursos provisionados:** 45 (terraform apply)
- **Destaques:** ECS EC2 launch type + Capacity Provider + ASG + ALB + RDS + patch VITE_API_URL

### ✅ Desafio 03 - EC2 + SSH + SSM + Instance Connect

- **Pasta:** [`desafio_03_ec2_ssm_ssh/`](./desafio_03_ec2_ssm_ssh/)
- **Nível:** ⭐⭐ (2/3)
- **Categoria:** Linear
- **Data limite do post:** 01/06/2026
- **Carga estudo:** 22h22
- **Objetivo:** Conhecer modelos de conectividade EC2 e fluxo das informações.
- **Status:** ✅ Concluído (2026-05-24)
- **Custo real:** ~$0,30 (sessão ~3h)
- **Recursos provisionados:** 42 (terraform apply)
- **Destaques:** 5 metodos de conectividade EC2 validados + Ed25519 incompativel com Windows AMIs (ADR-002)

### ✅ Desafio 04 - NAT Gateway + ECS Privado

- **Pasta:** [`desafio_04_nat_gateway/`](./desafio_04_nat_gateway/)
- **Nível:** ⭐⭐ (2/3)
- **Categoria:** Não linear
- **Data limite do post:** 08/06/2026
- **Carga estudo:** 1d 3h59
- **Objetivo:** BIA + ECS em subnet privada com saída via NAT Gateway.
- **Status:** ✅ Concluído (2026-06-02)
- **Custo real:** ~$0.22 (sessão ~3h)
- **Recursos provisionados:** 33 (terraform apply)
- **Destaques:** ECS Fargate assign_public_ip=false + NAT GW single + RDS privado + migrations via ECS run-task

### ✅ Desafio 05 - VPC + VPC Peering

- **Pasta:** [`desafio_05_vpc_peering/`](./desafio_05_vpc_peering/)
- **Nível:** ⭐⭐⭐ (3/3)
- **Categoria:** Linear
- **Data limite do post:** 08/06/2026
- **Carga estudo:** 12h29
- **Objetivo:** Comunicacao cross-region entre us-east-1 e us-east-2 via VPC Peering.
- **Status:** ✅ Concluído (2026-06-08)
- **Custo real:** ~$0.06 (sessao ~2h)
- **Recursos provisionados:** 22 (terraform apply)
- **Destaques:** Dual-provider Terraform + VPC Peering cross-region + aceitacao automatica via `aws_vpc_peering_connection_accepter` + 3 smoke tests (SSH externo, ping via peering, SSH via peering)

### ✅ Desafio 06 - VPC Endpoint + SSM + Instance Connect

- **Pasta:** [`desafio_06_vpc_endpoint/`](./desafio_06_vpc_endpoint/)
- **Nivel:** 3/3
- **Categoria:** Nao linear
- **Data limite do post:** 08/06/2026
- **Carga estudo:** 7h29
- **Objetivo:** EC2 em subnet 100% privada gerenciada via SSM Session Manager e EC2 Instance Connect Endpoint, sem NAT Gateway e sem IP publico.
- **Status:** ✅ Concluído (2026-06-08)
- **Custo real:** ~$0.10 (sessao ~2h)
- **Recursos provisionados:** 18 (terraform apply)
- **Destaques:** VPC somente privada + 5 VPC Endpoints (3 SSM Interface + EIC + S3 Gateway) + SSH_AUTH_SOCK="" fix para EIC

---

## 💰 Resumo de Custos

| Desafio | Estimado | Real | Período Ativo |
|---|---:|---:|:---:|
| 01 | $0.03 | ~$0.03 | 2026-05-13 (~2h) |
| 02 | $0.24 | ~$0.23 | 2026-05-15 (~3h) |
| 03 | $0,30 | ~$0,30 | 2026-05-24 (~3h) |
| 04 | $0.22 | ~$0.22 | 2026-06-02 (~3h) |
| 05 | $0.06 | ~$0.06 | 2026-06-08 (~2h) |
| 06 | $0.10 | ~$0.10 | 2026-06-08 (~2h) |
| **Total** | **-** | **-** | - |

> Atualizado por `make cost-report` ao final de cada desafio.

---

## 🎓 Lições Aprendidas (consolidadas ao final do mês)

_Preenchido após conclusão do último desafio._

---

## 🔗 Links Úteis

- [README do monorepo](./README.md)
- [Padrão de Tags AWS](./docs/AWS_TAGGING.md)
