#!/usr/bin/env bash
# Helper para listar prints da pasta docs/PRINTS/
set -euo pipefail
DIR="$(dirname "$0")/../docs/PRINTS"
echo "📸 Prints do Desafio 01:"
ls -la "$DIR" 2>/dev/null || echo "  (vazio)"
