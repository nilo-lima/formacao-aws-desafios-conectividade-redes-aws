#!/bin/bash
# Bootstrap da instância bia-dev (zona A — us-east-1a)
# Clona BIA de nilo-lima/bia.git e sobe via Docker Compose

set -euxo pipefail

# ─── Sistema e Docker ─────────────────────────────────────────────
dnf update -y
dnf install -y docker git
systemctl enable --now docker
usermod -aG docker ec2-user

# ─── Docker Compose v2 (standalone) ──────────────────────────────
curl -SL \
  "https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64" \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# ─── Clonar BIA (fonte exclusiva: nilo-lima/bia — ADR-004) ───────
git clone https://github.com/nilo-lima/bia.git /opt/bia
cd /opt/bia

# ─── IP público via IMDSv2 ────────────────────────────────────────
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PUBLIC_IP=$(curl -s \
  -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/public-ipv4)

# ─── Variáveis de ambiente para o compose ────────────────────────
cat > /opt/bia/.env <<EOF
VITE_API_URL=http://${PUBLIC_IP}:3001
EOF

# ─── Subir aplicação ─────────────────────────────────────────────
docker-compose up -d

# ─── Log de conclusão ─────────────────────────────────────────────
echo "bia-dev bootstrap concluído — IP: ${PUBLIC_IP}" >> /var/log/bia-bootstrap.log
