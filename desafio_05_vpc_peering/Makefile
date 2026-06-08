# Desafio 05: VPC + VPC Peering (multi-região)
.DEFAULT_GOAL := help
.PHONY: help init plan apply diagram validate destroy up down publish clean

TF_DIR := terraform
DOCS_DIR := docs

init: ## terraform init
	cd $(TF_DIR) && terraform init

fmt: ## terraform fmt
	cd $(TF_DIR) && terraform fmt -recursive

validate: ## terraform validate + tflint + tfsec
	cd $(TF_DIR) && terraform validate
	@command -v tflint >/dev/null && (cd $(TF_DIR) && tflint) || echo "tflint não instalado, pulando"
	@command -v tfsec >/dev/null && (cd $(TF_DIR) && tfsec .) || echo "tfsec não instalado, pulando"

plan: init fmt ## terraform plan -out=tfplan
	cd $(TF_DIR) && terraform plan -out=tfplan

apply: ## terraform apply (use após /deploy-aws)
	cd $(TF_DIR) && terraform apply tfplan

destroy: ## ⚠️ terraform destroy (dupla confirmação no chat via Claude)
	cd $(TF_DIR) && terraform destroy

diagram: ## Gera docs/architecture.png
	cd $(DOCS_DIR) && python3 architecture.py
	@ls -la $(DOCS_DIR)/architecture.png

up: init plan apply ## init + plan + apply (sequência completa)

down: destroy ## alias de destroy

publish: ## Executa Fase 5 (gera/atualiza README, blog, slides)
	@echo "Use /publicar-desafio no Claude Code para executar a Fase 5 completa"

outputs: ## Mostra outputs do Terraform
	cd $(TF_DIR) && terraform output

prints: ## Lista prints existentes em docs/PRINTS/
	@ls -la $(DOCS_DIR)/PRINTS/ 2>/dev/null || echo "Nenhum print ainda. Crie a pasta: mkdir -p $(DOCS_DIR)/PRINTS"

clean: ## Remove arquivos temporários (preserva *.tf, *.md, prints)
	rm -f $(TF_DIR)/tfplan $(TF_DIR)/*.log
	rm -rf $(TF_DIR)/.terraform/
	@echo "Limpo. State e arquivos versionados preservados."

help: ## Mostra esta ajuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
