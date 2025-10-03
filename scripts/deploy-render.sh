#!/bin/bash

# Script para Deploy Simplificado no Render.com
# Container Único: n8n + Evolution API

echo "🚀 Preparando Deploy para Render.com (Container Único)..."

# Verificar se estamos no diretório correto
if [ ! -f "Dockerfile" ]; then
    echo "❌ Dockerfile não encontrado!"
    echo "📁 Execute este script na raiz do projeto"
    exit 1
fi

# Verificar se o git está configurado
if ! git status >/dev/null 2>&1; then
    echo "❌ Este diretório não é um repositório Git!"
    echo "📋 Inicialize o git primeiro: git init"
    exit 1
fi

echo "✅ Dockerfile encontrado"
echo "✅ Repositório Git configurado"

# Verificar arquivos essenciais
echo ""
echo "📋 Verificando arquivos essenciais..."

if [ ! -f ".env.render" ]; then
    echo "⚠️  .env.render não encontrado (opcional)"
else
    echo "✅ .env.render encontrado"
fi

if [ ! -f "RENDER-EVOLUTION-SETUP.md" ]; then
    echo "⚠️  Documentação não encontrada"
else
    echo "✅ Documentação encontrada"
fi

# Mostrar estrutura atual
echo ""
echo "📁 Estrutura atual do projeto:"
echo "├── Dockerfile (multi-serviço)"
echo "├── .env.render (configurações)"
echo "├── docker-compose.yml (desenvolvimento local)"
echo "├── docker-compose.prod.yml (produção auto-hospedada)"
echo "└── RENDER-EVOLUTION-SETUP.md (documentação)"

echo ""
echo "🎯 PRÓXIMOS PASSOS PARA DEPLOY NO RENDER:"
echo ""
echo "1. 📤 PUSH PARA GITHUB:"
echo "   git add ."
echo "   git commit -m \"Configure container único para Render.com\""
echo "   git push origin main"
echo ""
echo "2. 🗄️  CONFIGURAR BANCOS NO RENDER:"
echo "   - PostgreSQL: New → PostgreSQL (nome: n8n-evolution-postgres)"
echo "   - Redis: New → Redis (nome: n8n-evolution-redis)"
echo ""
echo "3. 🚀 CRIAR WEB SERVICE NO RENDER:"
echo "   - New → Web Service"
echo "   - Repository: seu-repositorio-github"
echo "   - Dockerfile Path: ./Dockerfile"
echo ""
echo "4. ⚙️  CONFIGURAR VARIÁVEIS DE AMBIENTE:"
echo "   === OBRIGATÓRIAS ==="
echo "   N8N_BASIC_AUTH_USER=admin"
echo "   N8N_BASIC_AUTH_PASSWORD=sua_senha_forte_123"
echo "   AUTHENTICATION_API_KEY=sua_chave_evolution_api_123"
echo ""
echo "   === AUTOMÁTICAS (conectar bancos) ==="
echo "   DATABASE_URL=\${DATABASE_URL}"
echo "   REDIS_URL=\${REDIS_URL}"
echo ""
echo "5. 🌐 URLS DE ACESSO (após deploy):"
echo "   N8N: https://seu-app.onrender.com"
echo "   Evolution API: https://seu-app.onrender.com:8080"
echo "   Manager: https://seu-app.onrender.com:8080/manager"
echo ""
echo "📚 Consulte RENDER-EVOLUTION-SETUP.md para instruções detalhadas!"
echo ""
echo "✨ Pronto para deploy! Execute os comandos git acima."