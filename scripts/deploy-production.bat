@echo off
REM Script para Deploy em Produção Auto-hospedada (Windows)
REM Este script configura e inicia todos os serviços em produção

echo 🚀 Iniciando Deploy em Produção...

REM Verificar se o arquivo .env.prod existe
if not exist ".env.prod" (
    echo ❌ Arquivo .env.prod não encontrado!
    echo 📋 Copie .env.prod.example e configure as variáveis necessárias
    pause
    exit /b 1
)

REM Parar serviços existentes se estiverem rodando
echo 🛑 Parando serviços existentes...
docker-compose -f docker-compose.prod.yml down

REM Limpar volumes antigos se especificado
if "%1"=="--clean" (
    echo 🧹 Limpando volumes antigos...
    docker-compose -f docker-compose.prod.yml down -v
)

REM Fazer pull das imagens mais recentes
echo 📥 Atualizando imagens Docker...
docker-compose -f docker-compose.prod.yml pull

REM Iniciar serviços em produção
echo ▶️ Iniciando serviços em produção...
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d

REM Aguardar serviços subirem
echo ⏳ Aguardando serviços iniciarem...
timeout /t 30 /nobreak >nul

REM Verificar status dos serviços
echo 🔍 Verificando status dos serviços...
docker-compose -f docker-compose.prod.yml ps

echo.
echo ✅ Deploy concluído!
echo.
echo 📋 URLs de acesso:
echo 🔗 n8n: http://localhost:5678
echo 🔗 Evolution API: http://localhost:8080
echo 🔗 Adminer: http://localhost:8081
echo.
echo 👤 Credenciais n8n:
echo    User: admin
echo    Password: [configurado no .env.prod]
echo.
echo 📊 Para ver logs: docker-compose -f docker-compose.prod.yml logs -f
echo 🛑 Para parar: docker-compose -f docker-compose.prod.yml down
echo.
pause