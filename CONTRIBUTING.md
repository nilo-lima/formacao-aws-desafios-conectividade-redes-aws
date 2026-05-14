# 🤝 Guia de Contribuição

Obrigado pelo interesse em contribuir com este monorepo de laboratórios AWS!

---

## 📋 Antes de começar

- Leia o [`README.md`](README.md) para entender a estrutura do projeto.
- Leia o [`PROJECTS.md`](PROJECTS.md) para ver o status atual dos desafios.
- Consulte o [`CLAUDE.md`](CLAUDE.md) para entender as regras e padrões obrigatórios.

---

## 🌳 Estrutura do Repositório

```text
formacao-aws-desafios-conectividade-redes-aws/   ← raiz do GitHub
├── README.md          # Visão geral do monorepo
├── PROJECTS.md        # Dashboard de progresso dos 6 desafios
├── CONTRIBUTING.md    # Este arquivo
├── LICENSE            # Apache 2.0
├── .gitignore         # Ignora tfstate, .env, *.pem, .terraform/, etc.
├── CLAUDE.md          # Constituição do Claude Code (padrões e fluxos)
├── Makefile           # Targets globais: vm-up, lint, cost-report, destroy-all
├── Vagrantfile        # VM Debian 12 isolada para execução dos labs
├── setup.sh           # Provisionamento da VM (Terraform, Ansible, Docker, etc.)
├── docs/              # Padrões compartilhados (ARCHITECTURE, TAGGING, COST, BIA)
├── shared/            # Módulos Terraform + playbooks Ansible + templates
│   ├── modules/       # vpc, bia-baseline, ecs-fargate, nat-gateway, vpc-endpoints, observability
│   ├── ansible/       # playbooks + roles reutilizáveis
│   ├── scripts/       # automações globais
│   ├── python/        # helpers diagrams + boto3
│   └── templates/     # esqueletos para novos desafios
├── sources/           # Planilha-fonte da formação
└── desafio_NN_slug/   # Um diretório por desafio (01 a 06)
    ├── ai/            # PRD.md, CLAUDE.md local, ADRs
    ├── terraform/     # IaC (consome shared/modules)
    ├── docs/          # architecture.png, BLOG_POST, SLIDES, KIRO, CUSTOS
    ├── scripts/       # user_data, validate, cleanup
    ├── Makefile       # Targets locais do desafio
    ├── .gitignore     # (herdado do raiz — pode ter adições locais)
    └── README.md      # README de elite em 13 seções canônicas
```

---

## ✅ O que pode ser contribuído

- **Correções de bugs** no Terraform, scripts ou documentação.
- **Melhorias nos módulos `shared/`** — retrocompatíveis e com testes.
- **Novos templates** em `shared/templates/`.
- **Atualização de documentação** — README, ADRs, BLOG_POST.
- **Tradução ou melhoria das perguntas Kiro** em `docs/KIRO_QUESTIONS.md`.

---

## 🚫 O que não aceitar via PR

- Arquivos `.tfstate`, `.tfvars` com senhas, `.env`, `*.pem` (use `.gitignore`).
- Modificações que quebrem a estrutura canônica de `desafio_NN_slug/`.
- Código que não carregue as 7 tags Well-Architected em todos os recursos AWS.
- PRs sem descrição ou sem `terraform validate` executado.

---

## 📝 Convenção de Commits

Este projeto usa **Conventional Commits em PT-BR**:

```
<tipo>(<escopo>): <descrição curta>

[corpo opcional]

Co-Authored-By: Nome <email>
```

### Tipos aceitos

| Tipo | Quando usar |
|---|---|
| `feat` | Nova funcionalidade ou novo desafio |
| `fix` | Correção de bug |
| `docs` | Apenas documentação |
| `chore` | Manutenção (deps, CI, tooling) |
| `refactor` | Refatoração sem mudança de comportamento |
| `infra` | Mudança de infraestrutura AWS |

### Exemplos

```bash
feat(desafio-01): VPC customizada com 2 subnets públicas e IGW
fix(shared/vpc): corrigir output private_route_table_ids quando lista vazia
docs(desafio-02): atualizar BLOG_POST com custo real apurado
infra(shared/modules): adicionar módulo alb para desafio 02
```

---

## 🔀 Fluxo de Pull Request

1. **Fork** o repositório.
2. Crie uma branch descritiva: `feat/desafio-02-ecs` ou `fix/vpc-module-outputs`.
3. Siga os padrões do `CLAUDE.md` (tags, estrutura de diretórios, commits).
4. Execute localmente antes de abrir o PR:
   ```bash
   terraform fmt -recursive
   terraform validate
   # tflint e tfsec se disponíveis
   ```
5. Abra o PR com descrição clara: **o quê**, **por quê** e **como testar**.
6. Aguarde revisão — PRs sem `terraform validate` passando serão fechados.

---

## 🏷️ Tags de Desafios Concluídos

Cada desafio concluído recebe uma tag Git no formato `vNN-slug`:

```bash
git tag v01-vpc -m "Desafio 01 concluído: VPC + Subnet Pública"
git tag v02-ecs -m "Desafio 02 concluído: ECS Fargate Multi-AZ"
```

---

## 🛡️ Padrões de Segurança Inegociáveis

- **Nunca** commitar `*.tfvars` com senhas (use `*.tfvars.example`).
- **Nunca** commitar `*.pem`, `*.key` ou `credentials.json`.
- **IMDSv2 obrigatório** em todas as EC2 (`http_tokens = "required"`).
- **Porta 22 não exposta** — acesso via SSM Session Manager.
- **7 tags Well-Architected** em 100% dos recursos Terraform.

---

## 📞 Dúvidas

Abra uma **Issue** com o label `question` descrevendo sua dúvida.

---

> Projeto da **Formação AWS 5.0 — Mentoria Desafio Labs 2.0** · Mentor: Henrylle Maia
