# 🚀 Formação AWS 5.0 · Desafio Labs 2.0 · Mai/2026

> **Conectividade e Redes na AWS** — 6 desafios práticos com IaC, automação e documentação de elite.
> Monorepo orquestrado por **Claude Code** em modo Mentor Híbrido.

[![Terraform](https://img.shields.io/badge/IaC-Terraform-7B42BC?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Ansible](https://img.shields.io/badge/Config-Ansible-EE0000?logo=ansible&logoColor=white)](https://www.ansible.com/)
[![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazonaws&logoColor=white)](https://aws.amazon.com/)
[![Docker](https://img.shields.io/badge/Container-Docker-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Vagrant](https://img.shields.io/badge/Env-Vagrant-1868F2?logo=vagrant&logoColor=white)](https://www.vagrantup.com/)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](LICENSE)

---

## 📋 Sobre o Projeto

Este monorepo contém a implementação **production-ready** dos 6 desafios mensais da **Mentoria Desafio Labs 2.0** da Formação AWS 5.0, sob a curadoria do mentor **Henrylle Maia**.

Cada desafio é um projeto autocontido, com:

- ✅ **Infraestrutura como Código** (Terraform + módulos reutilizáveis)
- ✅ **Configuração automatizada** (Ansible + Docker)
- ✅ **Diagramas profissionais** (Python `diagrams` + ícones oficiais AWS)
- ✅ **Documentação de elite** (README canônico em 13 seções)
- ✅ **Evidências completas** (prints do console, custos reais, smoke tests)
- ✅ **Inteligência embarcada** (`CLAUDE.md`, `PRD.md`, ADRs, prompts)

---

## 🎯 Desafios do Mês

| # | Serviço | Nível | Data Limite | Status |
|---|---|:---:|---|:---:|
| [01](./desafio_01_vpc/) | VPC + Subnet Pública | 1 | 18/05/2026 | ✅ Concluído |
| [02](./desafio_02_ecs_publico/) | VPC + Subnet Pública + ECS | 2 | 25/05/2026 | 🟡 Aguardando |
| [03](./desafio_03_ec2_ssm_ssh/) | EC2 + VPC + SSH + SSM + Instance Connect | 2 | 01/06/2026 | 🟡 Aguardando |
| [04](./desafio_04_nat_gateway/) | NAT Gateway | 2 | 08/06/2026 | 🟡 Aguardando |
| [05](./desafio_05_vpc_peering/) | VPC + VPC Peering | 3 | 08/06/2026 | 🟡 Aguardando |
| [06](./desafio_06_vpc_endpoint/) | VPC Endpoint + SSM + EC2 Instance Connect | 3 | 08/06/2026 | 🟡 Aguardando |

> 📊 Dashboard completo de progresso em [PROJECTS.md](./PROJECTS.md)

---

## 🏗️ Arquitetura do Monorepo

```text
desafios_maio_2026/
├── .claude/                      # Constituição + slash commands Claude Code
├── docs/                         # Padrões compartilhados (arquitetura, tagging, FinOps)
├── shared/                       # Módulos Terraform + playbooks Ansible + scripts
│   ├── modules/                  # vpc, bia-baseline, ecs-fargate, nat-gateway, vpc-endpoints
│   ├── ansible/                  # playbooks + roles reutilizáveis
│   ├── scripts/                  # deploy, destroy, cost-report, new-challenge
│   ├── python/                   # helpers diagrams + boto3
│   └── templates/                # esqueletos para novos desafios
├── desafio_NN_slug/              # 6 pastas, uma por desafio
│   ├── ai/                       # CLAUDE.md, PRD.md, ADRs locais
│   ├── terraform/                # IaC (consome shared/modules)
│   ├── ansible/                  # configuração pós-deploy
│   ├── docker/                   # compose para BIA local
│   ├── docs/                     # architecture.py, PRINTS/, BLOG_POST, SLIDES, KIRO
│   ├── scripts/                  # automações locais
│   ├── Makefile                  # atalhos
│   └── README.md                 # README de elite (gerado na F5)
├── sources/                      # Planilha original + guia da VM Vagrant
├── Vagrantfile / setup.sh        # Estação de trabalho isolada (Debian 12)
├── Makefile                      # Controle global do monorepo
├── PROJECTS.md                   # Dashboard de progresso
├── CLAUDE.md                     # Constituição do Claude Code
└── README.md                     # Este arquivo
```

---

## 🧠 Inteligência Claude Code

Este monorepo é projetado para uso intensivo do **Claude Code** como mentor técnico:

- **`CLAUDE.md` raiz:** constituição global, fluxo de 5 fases, permissões executivas, padrões IaC.
- **`CLAUDE.md` por desafio:** persona específica, critérios de aceite, lições aprendidas.
- **Slash commands:** `/novo-desafio`, `/plan-arquitetura`, `/deploy-aws`, `/destroy-aws`, `/publicar-desafio`.
- **PRD por desafio:** objetivo, KRs, escopo, fora de escopo, riscos.
- **ADRs numerados:** justificativa técnica de cada decisão de arquitetura.

---

## 🚀 Guia de Execução

### Pré-requisitos no host

- [VirtualBox](https://www.virtualbox.org/) + [Vagrant](https://www.vagrantup.com/) (para a VM Debian 12 isolada)
- Conta AWS com perfil configurado em `~/.aws/credentials` (region `us-east-1`)
- Acesso ao GitHub (SSH ou HTTPS)

### Subir o ambiente isolado

```bash
make vm-up        # Sobe a VM formacao-aws (192.168.56.250)
make vm-ssh       # Conecta na VM
```

Dentro da VM, todas as ferramentas estão pré-instaladas: Terraform, Ansible, Docker, AWS CLI v2, AWS SSM, Kiro CLI, LocalStack, `diagrams` (Python), `graphviz`.

### Trabalhar em um desafio

```bash
# Listar comandos disponíveis no Makefile global
make help

# Entrar em um desafio e ver atalhos locais
cd desafio_01_vpc && make help

# Fluxo típico (executado pelo Claude Code com aprovações)
make init plan          # inicializa + mostra plano
make apply              # aplica (pede confirmação)
make diagram            # gera architecture.png
make destroy            # destrói recursos (dupla confirmação)
```

### Targets globais

| Target | Descrição |
|---|---|
| `make vm-up` | Sobe a VM Vagrant |
| `make vm-ssh` | SSH na VM |
| `make vm-halt` | Desliga a VM |
| `make new-desafio NN=07 SLUG=alb-https` | Cria esqueleto de novo desafio |
| `make cost-report` | Relatório de custos consolidado do mês via Cost Explorer |
| `make lint` | Executa tflint+tfsec+ansible-lint em todos os desafios |
| `make destroy-all` | ⚠️ Destrói recursos de todos os desafios (dupla confirmação) |

---

## 🏷️ Padrão de Tagging AWS

Todo recurso provisionado carrega **7 tags Well-Architected** obrigatórias:

| Tag | Valor | Finalidade |
|---|---|---|
| `Project` | `formacao-aws` | Agrupamento macro |
| `Environment` | `lab` | Diferencia lab/prod |
| `Owner` | `nilo-lima-jr` | Responsável |
| `ManagedBy` | `terraform` | Como foi criado |
| `Challenge` | `mai2026-desafio-NN` | Isola por desafio no Cost Explorer |
| `CostCenter` | `formacao-aws-mai2026` | Agrupa custos do mês |
| `AutoShutdown` | `true` | Habilita rotina de desligamento |

> 📖 Detalhes em [docs/AWS_TAGGING.md](./docs/AWS_TAGGING.md).

---

## 💰 Controle de Custos

- **AWS Budgets** com alerta a partir de US$ 10/mês
- **Cost Explorer** consultado via tag `CostCenter=formacao-aws-mai2026`
- **AutoShutdown** noturno (futuro) para EC2/RDS com tag `AutoShutdown=true`
- **Cleanup obrigatório** ao final de cada desafio: `make destroy` + verificação de órfãos

> 📖 Política completa em [docs/COST_CONTROL.md](./docs/COST_CONTROL.md).

---

## 🤖 Perguntas para o Kiro

Cada desafio gera um arquivo `docs/KIRO_PERGUNTAS.md` com perguntas categorizadas em:

1. **🔍 Verificação de recursos** — auditoria por tag
2. **💰 Custos & FinOps** — Cost Explorer drill-down
3. **📊 Uso & Performance** — CloudWatch metrics
4. **🛡️ Segurança & Compliance** — IAM, SGs, dados sensíveis

> 📖 Banco mestre em [docs/KIRO_QUESTIONS.md](./docs/KIRO_QUESTIONS.md).

---

## 📈 Próximos Passos

- [ ] Concluir os 6 desafios de maio/2026
- [ ] Configurar OIDC GitHub Actions → AWS (sem access keys)
- [ ] Habilitar AutoShutdown Lambda + EventBridge
- [ ] Migrar tfstate para S3+DynamoDB (multi-pessoa)
- [ ] Replicar para `desafios_junho_2026` ao final do ciclo

---

## 🎓 Lições Aprendidas

Cada desafio acumula lições em sua seção `🎓 Lições Aprendidas` do README local. Resumo consolidado será publicado em `PROJECTS.md` ao final do mês.

---

## 💖 Apoie este Projeto Open Source

Se você gosta dos meus projetos, considere:

- 🏆 Me indicar para o GitHub Stars: [Indicar Aqui](https://stars.github.com/nominate/)
- ⭐ Dar uma estrela no repositório
- 🐛 Reportar bugs ou melhorias
- 🤝 Contribuir com código
- 🐈‍⬛ Visitar meu perfil: [@nilo-lima](https://github.com/nilo-lima)

---

## ⚖️ Licença

Distribuído sob a licença **Apache 2.0**. Esta licença oferece permissão para uso, modificação e distribuição, além de garantir proteção contra disputas de patentes para colaboradores e usuários. Veja o arquivo [LICENSE](LICENSE) para mais informações.

---

<div align="center">
  <sub>
    Monorepo construído com
    <a href="https://www.anthropic.com/claude-code">Claude Code</a>
    no padrão
    <a href="https://github.com/nilo-lima/DevOps_Master_Lab">DevOps Master Lab</a>
    · Mentoria
    <a href="https://hotmart.com/pt-br/club/formacaoaws">Formação AWS 5.0 — Henrylle Maia</a>
  </sub>
</div>
