# Desafio 04: NAT Gateway + ECS Privado
.DEFAULT_GOAL := help
.PHONY: help init fmt validate plan apply destroy diagram up down \
        push-image redeploy outputs prints cost-report clean

TF_DIR   := terraform
DOCS_DIR := docs
REGION   := us-east-1
ECR_REPO := bia
BIA_FORK := https://github.com/nilo-lima/bia

init: ## terraform init
	cd $(TF_DIR) && terraform init

fmt: ## terraform fmt
	cd $(TF_DIR) && terraform fmt -recursive

validate: ## terraform validate + tflint + tfsec
	cd $(TF_DIR) && terraform validate
	@command -v tflint >/dev/null && (cd $(TF_DIR) && tflint) || echo "tflint nao instalado, pulando"
	@command -v tfsec  >/dev/null && (cd $(TF_DIR) && tfsec .) || echo "tfsec nao instalado, pulando"

plan: init fmt ## terraform plan -out=tfplan.out
	cd $(TF_DIR) && terraform plan -out=tfplan.out

apply: ## terraform apply (use apos confirmar o plan)
	cd $(TF_DIR) && terraform apply tfplan.out

destroy: ## ATENCAO: terraform destroy (dupla confirmacao)
	@echo "⚠️  DESTRUIR toda a infraestrutura do desafio 04?"
	@echo "   Pressione Ctrl+C para cancelar ou Enter para continuar."
	@read _confirm
	cd $(TF_DIR) && terraform destroy

outputs: ## Mostra outputs do Terraform
	cd $(TF_DIR) && terraform output

# ─── Workflow da imagem ECR ────────────────────────────────────────────────
# Executar APOS o primeiro terraform apply (ALB ja existe para pegar o DNS).

push-image: ## Clona fork, aplica patch VITE_API_URL, faz build e push para ECR
	@echo ">>> Verificando pre-requisitos..."
	@command -v docker >/dev/null || (echo "Docker nao encontrado" && exit 1)
	@command -v aws    >/dev/null || (echo "AWS CLI nao encontrado" && exit 1)
	$(eval ACCOUNT_ID := $(shell aws sts get-caller-identity --query Account --output text))
	$(eval ECR_URI    := $(ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com/$(ECR_REPO))
	$(eval ALB_DNS    := $(shell cd $(TF_DIR) && terraform output -raw alb_dns_name 2>/dev/null))
	@if [ -z "$(ALB_DNS)" ]; then echo "ALB DNS nao encontrado. Execute 'make apply' primeiro."; exit 1; fi
	@echo ">>> ALB DNS: $(ALB_DNS)"
	@echo ">>> Clonando fork da BIA..."
	@rm -rf /tmp/bia-build && git clone $(BIA_FORK) /tmp/bia-build
	@echo ">>> Aplicando patch VITE_API_URL no Dockerfile..."
	@grep -q 'ARG VITE_API_URL' /tmp/bia-build/Dockerfile || \
	  sed -i '/RUN cd client && VITE_API_URL=http/i ARG VITE_API_URL=http://localhost:3001' /tmp/bia-build/Dockerfile
	@sed -i 's|VITE_API_URL=http://localhost:3001 npm run build|VITE_API_URL=$${VITE_API_URL} npm run build|' /tmp/bia-build/Dockerfile
	@echo ">>> Login no ECR..."
	@aws ecr get-login-password --region $(REGION) | \
	  docker login --username AWS --password-stdin $(ECR_URI)
	@echo ">>> Build da imagem com VITE_API_URL=http://$(ALB_DNS)..."
	@docker build \
	  --build-arg VITE_API_URL=http://$(ALB_DNS) \
	  -t $(ECR_URI):latest \
	  /tmp/bia-build
	@echo ">>> Push para ECR..."
	@docker push $(ECR_URI):latest
	@echo ">>> Imagem publicada: $(ECR_URI):latest"

redeploy: ## Forca novo deployment do ECS service (apos push-image)
	$(eval CLUSTER := $(shell cd $(TF_DIR) && terraform output -raw ecs_cluster_name 2>/dev/null))
	$(eval SERVICE := $(shell cd $(TF_DIR) && terraform output -raw ecs_service_name 2>/dev/null))
	@aws ecs update-service \
	  --region $(REGION) \
	  --cluster $(CLUSTER) \
	  --service $(SERVICE) \
	  --force-new-deployment \
	  --query 'service.{status:status,desired:desiredCount}' \
	  --output table
	@echo ">>> Aguardando tasks estabilizarem..."
	@aws ecs wait services-stable \
	  --region $(REGION) \
	  --cluster $(CLUSTER) \
	  --services $(SERVICE)
	@echo ">>> Service estavel!"

# ─── Utilidades ───────────────────────────────────────────────────────────────

diagram: ## Gera docs/architecture.png
	cd $(DOCS_DIR) && python3 architecture.py
	@ls -la $(DOCS_DIR)/architecture.png

cost-report: ## Custo do desafio nas ultimas 24h (requer tag Challenge ativa no Cost Explorer)
	@aws ce get-cost-and-usage \
	  --time-period Start=$$(date -d '24 hours ago' +%Y-%m-%d),End=$$(date +%Y-%m-%d) \
	  --granularity DAILY \
	  --metrics UnblendedCost \
	  --filter '{"Tags":{"Key":"Challenge","Values":["mai2026-desafio-04"]}}' \
	  --group-by Type=DIMENSION,Key=SERVICE \
	  --output table

up: init plan apply ## init + plan + apply (sequencia completa)

down: destroy ## alias de destroy

prints: ## Lista prints existentes em docs/PRINTS/
	@ls -la $(DOCS_DIR)/PRINTS/ 2>/dev/null || echo "Nenhum print ainda. Crie: mkdir -p $(DOCS_DIR)/PRINTS"

clean: ## Remove arquivos temporarios (preserva *.tf, *.md, prints)
	rm -f $(TF_DIR)/tfplan.out $(TF_DIR)/*.log
	rm -rf $(TF_DIR)/.terraform/
	@echo "Limpo. State e arquivos versionados preservados."

help: ## Mostra esta ajuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'
