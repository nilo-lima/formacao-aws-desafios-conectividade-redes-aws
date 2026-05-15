#!/bin/bash
# build-push.sh — Build da imagem BIA e push para ECR (Desafio 02)
# Aplica patch no Dockerfile do repo henrylle/bia antes do build:
# VITE_API_URL é hardcoded no Dockerfile original; o patch expõe como ARG.
# Executar na bia-dev (i-0bc...) via SSM após terraform apply.

set -euo pipefail

ECR_URL="507687687616.dkr.ecr.us-east-1.amazonaws.com/bia-repo-02"
REGION="us-east-1"
BIA_DIR="/opt/bia"
ALB_DNS="${1:-}"

if [[ -z "$ALB_DNS" ]]; then
  echo "Uso: $0 <ALB_DNS>"
  echo "Exemplo: $0 bia-02-alb-2133079818.us-east-1.elb.amazonaws.com"
  exit 1
fi

echo "==> Clone da BIA"
if [[ ! -d "$BIA_DIR" ]]; then
  sudo git clone https://github.com/henrylle/bia.git "$BIA_DIR"
fi

echo "==> Patch do Dockerfile (VITE_API_URL)"
if ! grep -q "ARG VITE_API_URL" "$BIA_DIR/Dockerfile"; then
  sudo sed -i '/RUN cd client && VITE_API_URL=http/i ARG VITE_API_URL=http://localhost:3001' "$BIA_DIR/Dockerfile"
  sudo sed -i 's|VITE_API_URL=http://localhost:3001 npm run build|VITE_API_URL=${VITE_API_URL} npm run build|' "$BIA_DIR/Dockerfile"
  echo "    Patch aplicado."
else
  echo "    Dockerfile já patcheado, pulando."
fi

echo "==> Login ECR"
aws ecr get-login-password --region "$REGION" | \
  sudo docker login --username AWS --password-stdin "$ECR_URL"

echo "==> Build (VITE_API_URL=http://$ALB_DNS)"
sudo docker build \
  --build-arg VITE_API_URL="http://$ALB_DNS" \
  -t "$ECR_URL:latest" \
  "$BIA_DIR"

echo "==> Push para ECR"
sudo docker push "$ECR_URL:latest"

echo ""
echo "Concluído. Próximo passo — force-new-deployment:"
echo "  aws ecs update-service --cluster bia-cluster-02 --service bia-svc-02 --force-new-deployment"
