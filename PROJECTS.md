# 📊 Dashboard de Progresso — Mai/2026

> **Mês:** Maio 2026 · **Trilha:** Conectividade e Redes na AWS
> **Carga estimada total:** 4 dias, 13h35m de estudos
> **Mentor:** Henrylle Maia (Formação AWS 5.0)

---

## 🎯 Resumo Visual

| Status | Quantidade | % |
|---|:---:|:---:|
| ✅ Concluído | 2 | 33% |
| 🔵 Em andamento | 0 | 0% |
| 🟡 Aguardando | 4 | 67% |
| ❌ Bloqueado | 0 | 0% |

```
██████░░░░░░░░░░░░░░  2/6  (33%)
```

---

## 📋 Detalhamento dos Desafios

### ✅ Desafio 01 — VPC + Subnet Pública

- **Pasta:** [`desafio_01_vpc/`](./desafio_01_vpc/)
- **Nível:** ⭐ (1/3)
- **Categoria:** Não linear
- **Data limite do post:** 18/05/2026
- **Carga estudo:** 11h33
- **Objetivo:** Lançar a `bia-dev` em subnet pública customizada, criar VPC manual e visual.
- **Status:** ✅ Concluído (2026-05-13)
- **Custo real:** ~$0.03 (sessão ~2h)
- **Repositório:** [formacao-aws-desafios-conectividade-redes-aws](https://github.com/nilo-lima/formacao-aws-desafios-conectividade-redes-aws)

### ✅ Desafio 02 — VPC + Subnet Pública + ECS

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

### 🟡 Desafio 03 — EC2 + SSH + SSM + Instance Connect

- **Pasta:** [`desafio_03_ec2_ssm_ssh/`](./desafio_03_ec2_ssm_ssh/)
- **Nível:** ⭐⭐ (2/3)
- **Categoria:** Linear
- **Data limite do post:** 01/06/2026
- **Carga estudo:** 22h22
- **Objetivo:** Conhecer modelos de conectividade EC2 e fluxo das informações.
- **Status:** 🟡 Aguardando

### 🟡 Desafio 04 — NAT Gateway

- **Pasta:** [`desafio_04_nat_gateway/`](./desafio_04_nat_gateway/)
- **Nível:** ⭐⭐ (2/3)
- **Categoria:** Não linear
- **Data limite do post:** 08/06/2026
- **Carga estudo:** 1d 3h59
- **Objetivo:** BIA + ECS em subnet privada com saída via NAT Gateway.
- **Status:** 🟡 Aguardando

### 🟡 Desafio 05 — VPC + VPC Peering

- **Pasta:** [`desafio_05_vpc_peering/`](./desafio_05_vpc_peering/)
- **Nível:** ⭐⭐⭐ (3/3)
- **Categoria:** Linear
- **Data limite do post:** 08/06/2026
- **Carga estudo:** 12h29
- **Objetivo:** Comunicação entre regiões via VPC Peering.
- **Status:** 🟡 Aguardando

### 🟡 Desafio 06 — VPC Endpoint + SSM + Instance Connect

- **Pasta:** [`desafio_06_vpc_endpoint/`](./desafio_06_vpc_endpoint/)
- **Nível:** ⭐⭐⭐ (3/3)
- **Categoria:** Não linear
- **Data limite do post:** 08/06/2026
- **Carga estudo:** 7h29
- **Objetivo:** Acesso seguro à VPC com SSM + VPC Endpoint + EC2 Instance Connect.
- **Status:** 🟡 Aguardando

---

## 💰 Resumo de Custos

| Desafio | Estimado | Real | Período Ativo |
|---|---:|---:|:---:|
| 01 | $0.03 | ~$0.03 | 2026-05-13 (~2h) |
| 02 | $0.24 | ~$0.23 | 2026-05-15 (~3h) |
| 03 | - | - | - |
| 04 | - | - | - |
| 05 | - | - | - |
| 06 | - | - | - |
| **Total** | **-** | **-** | - |

> Atualizado por `make cost-report` ao final de cada desafio.

---

## 🎓 Lições Aprendidas (consolidadas ao final do mês)

_Preenchido após conclusão do último desafio._

---

## 🔗 Links Úteis

- [README do monorepo](./README.md)
- [Padrão de Tags AWS](./docs/AWS_TAGGING.md)
