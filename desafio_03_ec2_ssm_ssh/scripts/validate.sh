#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

echo "▶ terraform fmt"
cd terraform && terraform fmt -recursive -check
cd ..

echo "▶ terraform validate"
cd terraform && terraform validate
cd ..

if command -v tflint >/dev/null; then
  echo "▶ tflint"
  cd terraform && tflint
  cd ..
fi

if command -v tfsec >/dev/null; then
  echo "▶ tfsec"
  cd terraform && tfsec .
  cd ..
fi

echo "✓ Validação concluída"
