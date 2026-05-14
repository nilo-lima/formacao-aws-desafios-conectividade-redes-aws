# ADR-004 — User data clona BIA exclusivamente de nilo-lima/bia.git

- **Status:** Aceito
- **Data:** 2026-05-13
- **Desafio:** 01 — VPC + Subnet Pública

## Contexto

O PRD (seção 4) instrui: "O Download da aplicação bia deve ser realizado EXCLUSIVAMENTE
de https://github.com/nilo-lima/bia.git". O `BIA_OVERVIEW.md` da raiz aponta para
`henrylle/bia` — divergência que precisava de decisão explícita.

## Decisão

O script `scripts/user_data_ec2_zona_a.sh` clona de:
```
https://github.com/nilo-lima/bia.git
```
Qualquer referência a `henrylle/bia` neste desafio é inválida e deve ser corrigida.

## Consequências

- Garante que a versão de BIA usada é a fork do Nilo Lima, com possíveis customizações
  específicas da formação.
- `BIA_OVERVIEW.md` na raiz continua apontando para `henrylle/bia` (repositório upstream)
  — não será alterado pois é documentação geral do monorepo, não instrução de deploy.
