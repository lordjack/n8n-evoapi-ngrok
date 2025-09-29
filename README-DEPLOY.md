# README - Como usar as configurações

## 🏠 **Desenvolvimento Local (com ngrok)**

### Pré-requisitos
- Docker e Docker Compose instalados
- ngrok instalado e configurado

### Como usar:
```bash
# Iniciar ambiente de desenvolvimento
npm run dev
# ou
scripts/start-dev.bat

# Ver logs
npm run dev:logs

# Parar
npm run dev:down
```

### URLs de acesso:
- **n8n**: http://localhost:5678
- **Evolution API**: http://localhost:8080
- **ngrok dashboard**: http://localhost:4040
- **Adminer**: http://localhost:8081

---

## ☁️ **Produção (Render.com)**

### Configuração no Render:

1. **Conecte seu repositório** ao Render.com

2. **Configure as variáveis de ambiente**:
   ```
   NODE_ENV=production
   N8N_PASSWORD=sua_senha_segura
   AUTHENTICATION_API_KEY=CqSRI6BrIlz45prK3KcLNjBTf+/moPvesMRCYYX5LGQ=
   ```

3. **Adicione serviços PostgreSQL e Redis** no Render

4. **Configure o Dockerfile**:
   - Use `Dockerfile.render`
   - Build Command: `echo "Build ready"`
   - Start Command: `n8n start`

### Estrutura de arquivos:
```
├── docker-compose.dev.yml    # Desenvolvimento local
├── docker-compose.prod.yml   # Produção (sem ngrok)
├── .env.dev                  # Variáveis de desenvolvimento
├── .env.prod                 # Variáveis de produção
├── Dockerfile.render         # Dockerfile para Render.com
├── render.yaml              # Configuração do Render
└── scripts/
    ├── start-dev.bat        # Script para desenvolvimento
    └── start-production.sh  # Script para produção
```

---

## 🔧 **Diferenças entre Ambientes**

### Desenvolvimento:
- ✅ ngrok para URLs públicas
- ✅ Todos os serviços locais
- ✅ Desenvolvimento e testes

### Produção:
- ✅ URLs estáticas do Render
- ✅ PostgreSQL e Redis gerenciados
- ✅ SSL/HTTPS automático
- ✅ Escalabilidade

---

## 🚀 **Deploy no Render**

1. **Faça push do código** para o GitHub
2. **Conecte o repositório** no Render.com
3. **Configure as variáveis** de ambiente
4. **Selecione `Dockerfile.render`** como Dockerfile
5. **Deploy automático** ativado!

### URLs após deploy:
- **n8n**: https://seu-app.onrender.com
- **Evolution API**: https://seu-app-api.onrender.com

---

## 📱 **Configuração do WhatsApp**

Após o deploy, configure o webhook:
```bash
curl -X POST "https://seu-app-api.onrender.com/webhook/set/teste" \
  -H "apikey: CqSRI6BrIlz45prK3KcLNjBTf+/moPvesMRCYYX5LGQ=" \
  -H "Content-Type: application/json" \
  -d '{"webhook": {"url": "https://seu-app.onrender.com/webhook-test/messages-upsert", "events": ["MESSAGES_UPSERT"], "enabled": true}}'
```