@echo off
echo 🚀 Iniciando ambiente de desenvolvimento com ngrok...

echo ⏳ Parando containers existentes...
docker-compose -f docker-compose.dev.yml --env-file .env.dev down

echo 🔧 Iniciando containers de desenvolvimento...
docker-compose -f docker-compose.dev.yml --env-file .env.dev up -d

echo ⏳ Aguardando containers iniciarem...
timeout /t 30 >nul

echo 🌐 Verificando URLs do ngrok...
curl -s http://localhost:4040/api/tunnels

echo ✅ Ambiente de desenvolvimento iniciado!
echo 📝 URLs de acesso:
echo    - n8n local: http://localhost:5678
echo    - Evolution API local: http://localhost:8080
echo    - ngrok dashboard: http://localhost:4040
echo.
echo 🔗 Para obter URLs públicas do ngrok, execute:
echo    curl http://localhost:4040/api/tunnels
echo.
pause