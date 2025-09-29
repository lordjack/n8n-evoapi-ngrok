@echo off
echo 🧪 Testando Dockerfile localmente antes do deploy...
echo.

echo 🔨 Fazendo build da imagem...
docker build -t n8n-render-test .

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Erro no build do Docker!
    pause
    exit /b 1
)

echo ✅ Build concluído com sucesso!
echo.
echo 🚀 Testando se n8n inicia corretamente...
echo ⏳ Aguarde alguns segundos...

docker run --rm -d --name n8n-test -p 15678:5678 ^
  -e N8N_BASIC_AUTH_USER=admin ^
  -e N8N_BASIC_AUTH_PASSWORD=test123 ^
  -e NODE_ENV=production ^
  n8n-render-test

timeout /t 15 >nul

echo 📋 Verificando logs do container...
docker logs n8n-test

echo.
echo 🌐 Testando se n8n responde...
timeout /t 20 >nul
curl -s -o nul -w "Status: %%{http_code}" http://localhost:15678/healthz
echo.

echo 🛑 Parando container de teste...
docker stop n8n-test

echo.
echo ✅ Teste concluído! 
echo 📝 Se viu "Status: 200" acima, o Dockerfile está OK para deploy!
echo.
pause