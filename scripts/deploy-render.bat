@echo off
REM Script para Deploy Simplificado no Render.com (Windows)
REM Container Único: n8n + Evolution API

echo 🚀 Preparando Deploy para Render.com (Container Único)...

REM Verificar se estamos no diretório correto
if not exist "Dockerfile" (
    echo ❌ Dockerfile não encontrado!
    echo 📁 Execute este script na raiz do projeto
    pause
    exit /b 1
)

REM Verificar se o git está configurado
git status >nul 2>&1
if errorlevel 1 (
    echo ❌ Este diretório não é um repositório Git!
    echo 📋 Inicialize o git primeiro: git init
    pause
    exit /b 1
)

echo ✅ Dockerfile encontrado
echo ✅ Repositório Git configurado

REM Verificar arquivos essenciais
echo.
echo 📋 Verificando arquivos essenciais...

if not exist ".env.render" (
    echo ⚠️  .env.render não encontrado (opcional)
) else (
    echo ✅ .env.render encontrado
)

if not exist "RENDER-EVOLUTION-SETUP.md" (
    echo ⚠️  Documentação não encontrada
) else (
    echo ✅ Documentação encontrada
)

REM Mostrar estrutura atual
echo.
echo 📁 Estrutura atual do projeto:
echo ├── Dockerfile (multi-serviço)
echo ├── .env.render (configurações)
echo ├── docker-compose.yml (desenvolvimento local)
echo ├── docker-compose.prod.yml (produção auto-hospedada)
echo └── RENDER-EVOLUTION-SETUP.md (documentação)

echo.
echo 🎯 PRÓXIMOS PASSOS PARA DEPLOY NO RENDER:
echo.
echo 1. 📤 PUSH PARA GITHUB:
echo    git add .
echo    git commit -m "Configure container único para Render.com"
echo    git push origin main
echo.
echo 2. 🗄️  CONFIGURAR BANCOS NO RENDER:
echo    - PostgreSQL: New → PostgreSQL (nome: n8n-evolution-postgres)
echo    - Redis: New → Redis (nome: n8n-evolution-redis)
echo.
echo 3. 🚀 CRIAR WEB SERVICE NO RENDER:
echo    - New → Web Service
echo    - Repository: seu-repositorio-github
echo    - Dockerfile Path: ./Dockerfile
echo.
echo 4. ⚙️  CONFIGURAR VARIÁVEIS DE AMBIENTE:
echo    === OBRIGATÓRIAS ===
echo    N8N_BASIC_AUTH_USER=admin
echo    N8N_BASIC_AUTH_PASSWORD=sua_senha_forte_123
echo    AUTHENTICATION_API_KEY=sua_chave_evolution_api_123
echo.
echo    === AUTOMÁTICAS (conectar bancos) ===
echo    DATABASE_URL=${DATABASE_URL}
echo    REDIS_URL=${REDIS_URL}
echo.
echo 5. 🌐 URLS DE ACESSO (após deploy):
echo    N8N: https://seu-app.onrender.com
echo    Evolution API: https://seu-app.onrender.com:8080
echo    Manager: https://seu-app.onrender.com:8080/manager
echo.
echo 📚 Consulte RENDER-EVOLUTION-SETUP.md para instruções detalhadas!
echo.
echo ✨ Pronto para deploy! Execute os comandos git acima.
pause