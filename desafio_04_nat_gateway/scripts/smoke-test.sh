#!/usr/bin/env bash
# smoke-test.sh — Valida a stack do Desafio 04 e gera o print 04-smoke-test.png
# Uso: ./scripts/smoke-test.sh [--print]
#   --print  captura screenshot do terminal apos exibir os resultados (requer scrot)
set -euo pipefail

PRINTS_DIR="$(dirname "$0")/../docs/PRINTS"
PRINT_FILE="$PRINTS_DIR/04-smoke-test.png"
CAPTURE_PRINT=false

[[ "${1:-}" == "--print" ]] && CAPTURE_PRINT=true

# ─── Resolve ALB DNS a partir do terraform output ──────────────────────────────
TF_DIR="$(dirname "$0")/../terraform"
ALB=$(cd "$TF_DIR" && terraform output -raw alb_dns_name 2>/dev/null)
CLUSTER=$(cd "$TF_DIR" && terraform output -raw ecs_cluster_name 2>/dev/null)
SERVICE=$(cd "$TF_DIR" && terraform output -raw ecs_service_name 2>/dev/null)

if [[ -z "$ALB" ]]; then
  echo "ERRO: ALB DNS nao encontrado. Execute 'make apply' primeiro."
  exit 1
fi

mkdir -p "$PRINTS_DIR"

# ─── Header visual ─────────────────────────────────────────────────────────────
echo "========================================================"
echo "  Desafio 04 - NAT Gateway + ECS Privado"
echo "  Smoke Test"
echo "========================================================"
echo ""

# ─── Teste 1: Frontend HTTP 200 ────────────────────────────────────────────────
echo "[ 1/4 ] Frontend - HTTP status"
STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "http://$ALB/")
if [[ "$STATUS" == "200" ]]; then
  echo "        http://$ALB/"
  echo "        HTTP $STATUS  OK"
else
  echo "        FALHOU  HTTP $STATUS"
fi
echo ""

# ─── Teste 2: Versao da API ────────────────────────────────────────────────────
echo "[ 2/4 ] Versao da API"
VERSAO=$(curl -s --max-time 10 "http://$ALB/api/versao" 2>/dev/null || echo "ERRO")
echo "        http://$ALB/api/versao"
echo "        Resposta: $VERSAO"
echo ""

# ─── Teste 3: GET /api/tarefas ────────────────────────────────────────────────
echo "[ 3/4 ] GET /api/tarefas (RDS PostgreSQL)"
TAREFAS=$(curl -s --max-time 10 "http://$ALB/api/tarefas" 2>/dev/null)
COUNT=$(echo "$TAREFAS" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "ERRO")
echo "        http://$ALB/api/tarefas"
echo "        Tarefas no banco: $COUNT"
if [[ "$COUNT" != "ERRO" && "$COUNT" -gt 0 ]]; then
  echo "        Primeira tarefa:"
  echo "$TAREFAS" | python3 -c "
import sys, json
d = json.load(sys.stdin)
t = d[0]
print(f'          uuid  : {t.get(\"uuid\",\"-\")}')
print(f'          titulo: {t.get(\"titulo\",\"-\")}')
" 2>/dev/null
fi
echo ""

# ─── Teste 4: Task ECS em subnet privada ──────────────────────────────────────
echo "[ 4/4 ] Task ECS - isolamento de rede"
TASK_ARN=$(aws ecs list-tasks \
  --cluster "$CLUSTER" \
  --service-name "$SERVICE" \
  --query 'taskArns[0]' \
  --output text 2>/dev/null)

if [[ "$TASK_ARN" == "None" || -z "$TASK_ARN" ]]; then
  echo "        Nenhuma task em execucao."
else
  ENI_ID=$(aws ecs describe-tasks \
    --cluster "$CLUSTER" \
    --tasks "$TASK_ARN" \
    --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' \
    --output text 2>/dev/null)

  read -r PRIVATE_IP SUBNET PUBLIC_IP <<< "$(aws ec2 describe-network-interfaces \
    --network-interface-ids "$ENI_ID" \
    --query 'NetworkInterfaces[0].[PrivateIpAddress,SubnetId,Association.PublicDnsName]' \
    --output text 2>/dev/null)"

  echo "        IP privado : $PRIVATE_IP"
  echo "        Subnet     : $SUBNET"
  if [[ "$PUBLIC_IP" == "None" || -z "$PUBLIC_IP" ]]; then
    echo "        IP publico : None  <<< sem IP publico - NAT Gateway ativo"
  else
    echo "        IP publico : $PUBLIC_IP  <<< ATENCAO: IP publico encontrado"
  fi
fi

echo ""
echo "========================================================"
echo "  NAT Gateway EIP: $(cd "$TF_DIR" && terraform output -json nat_eip 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)[0])" 2>/dev/null || echo "N/A")"
echo "  ALB DNS        : $ALB"
echo "========================================================"

# ─── Captura de screenshot ────────────────────────────────────────────────────
if [[ "$CAPTURE_PRINT" == "true" ]]; then
  echo ""
  echo "Capturando screenshot em 3 segundos..."
  echo "Clique na janela do terminal para mante-la em foco."
  if command -v scrot &>/dev/null; then
    sleep 3
    scrot -u "$PRINT_FILE"
    echo "Print salvo: $PRINT_FILE"
  else
    echo "scrot nao encontrado. Instale com: sudo apt-get install -y scrot"
    echo "Ou capture manualmente e salve em: $PRINT_FILE"
  fi
fi
