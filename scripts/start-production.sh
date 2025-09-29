#!/bin/bash

# Script de inicialização para produção (Render.com)
echo "🚀 Iniciando n8n + Evolution API no Render.com..."

# Verificar variáveis de ambiente obrigatórias
if [ -z "$DATABASE_URL" ] || [ -z "$REDIS_URL" ]; then
    echo "❌ Erro: DATABASE_URL e REDIS_URL são obrigatórias"
    exit 1
fi

echo "✅ Variáveis de ambiente configuradas"

# Aguardar banco de dados estar disponível
echo "⏳ Aguardando banco de dados..."
until pg_isready -d "$DATABASE_URL"; do
    echo "Banco não está pronto, aguardando..."
    sleep 2
done

echo "✅ Banco de dados conectado"

# Iniciar n8n
echo "🎯 Iniciando n8n..."
exec n8n start