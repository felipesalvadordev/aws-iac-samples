#!/bin/bash
set -e

# 1. Caminhos Absolutos Claros
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# Sobe um nível para a raiz 'cloudwatch-monitoring-s3-lambda'
PARENT_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"

# 2. Forçar a criação do diretório local ANTES do Docker
# O Docker cria um arquivo se a pasta não existir, causando o erro 'Not a directory'
DEST_DIR="$PARENT_DIR"
mkdir -p "$DEST_DIR"

echo "----------------------------------------------------------"
echo "📂 Script local: $SCRIPT_DIR"
echo "🎯 Destino fixo: $DEST_DIR"
echo "----------------------------------------------------------"

# 3. Execução com montagem BIND explícita
# Mudamos o nome interno para /layer_build para evitar conflitos de sistema
docker run --rm \
  --platform linux/amd64 \
  --mount type=bind,source="$DEST_DIR",target=/layer_build \
  python:3.12-slim \
  bash -c "
    apt-get update -qq && apt-get install -y -qq zip > /dev/null 2>&1 && \
    mkdir -p /tmp/python/lib/python3.12/site-packages/ && \
    pip install --quiet Pillow==10.4.0 -t /tmp/python/lib/python3.12/site-packages/ && \
    cd /tmp && \
    zip -q -r pillow_layer.zip python/ && \
    # Copia para o caminho de montagem alvo
    cp pillow_layer.zip /layer_build/pillow_layer.zip && \
    echo '✅ Sucesso: O arquivo foi copiado para o host.'
  "

echo "✨ Verifique agora: $DEST_DIR/pillow_layer.zip"