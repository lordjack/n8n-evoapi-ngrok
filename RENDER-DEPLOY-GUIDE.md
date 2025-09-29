# 🚀 Deploy no Render.com - Guia Simplificado

## ✅ **Passo a Passo para Deploy**

### 1. **Conectar Repositório**
- Vá para [render.com](https://render.com)
- Conecte seu repositório GitHub `n8n-evoapi-ngrok`

### 2. **Criar Web Service**
- **Name**: `n8n-app` (ou nome de sua escolha)
- **Environment**: `Docker`
- **Build Command**: `echo "Build completed"`
- **Start Command**: `n8n start`
- **Dockerfile Path**: `Dockerfile` (usar o arquivo raiz)

### 3. **Configurar Variáveis de Ambiente**
```bash
# Obrigatórias - Configure no Render Dashboard:
NODE_ENV=production
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=sua_senha_super_segura_aqui
N8N_LOG_LEVEL=info
N8N_COMMUNITY_PACKAGES=n8n-nodes-evolution-api

# Banco de Dados - Será preenchido automaticamente:
DATABASE_URL=postgresql://... (automático quando criar PostgreSQL)
DB_TYPE=postgresdb

# Configurações extras:
N8N_METRICS=true
N8N_DEFAULT_TIMEZONE=America/Recife
N8N_BLOCK_ENV_ACCESS_IN_NODE=false
```

### 4. **Criar PostgreSQL Database**
- No dashboard do Render, crie um **PostgreSQL Database**
- Nome: `n8n-database`
- Plano: **Free**
- Copie a `DATABASE_URL` gerada e adicione nas variáveis do Web Service

### 5. **Configurar Ports**
- **Port**: `5678` (porta do n8n)

### 6. **Deploy!**
- Clique em **Deploy** 
- Aguarde o build completar
- Sua URL será: `https://n8n-app.onrender.com`

---

## 🔧 **Verificação após Deploy**

### Testear n8n:
```bash
# Health check
curl https://seu-app.onrender.com/healthz

# Acessar interface
# URL: https://seu-app.onrender.com
# User: admin
# Pass: sua_senha_super_segura_aqui
```

### URLs importantes:
- **n8n Interface**: `https://seu-app.onrender.com`
- **Webhook URL**: `https://seu-app.onrender.com/webhook-test/messages-upsert`
- **Health Check**: `https://seu-app.onrender.com/healthz`

---

## ⚡ **Configurações Opcionais**

### Para Evolution API (serviço separado):
Se quiser hospedar Evolution API também no Render, crie outro Web Service:
- **Image**: `evoapicloud/evolution-api:latest`
- **Port**: `8080`
- **Variáveis**: `AUTHENTICATION_API_KEY`, `DATABASE_URL`, etc.

### Webhook Configuration:
Após deploy, configure o webhook da Evolution API para apontar para:
```
https://seu-app.onrender.com/webhook-test/messages-upsert
```

---

## 🐛 **Troubleshooting**

### Se o build falhar:
1. Verifique se o Dockerfile está no root do projeto
2. Confirme se as variáveis de ambiente estão configuradas
3. Veja os logs no dashboard do Render

### Se n8n não iniciar:
1. Verifique se `DATABASE_URL` está configurada
2. Confirme se a senha do n8n está definida
3. Verifique logs de inicialização

### Logs úteis:
```bash
# No dashboard do Render, vá em "Logs" para ver:
# - Build logs
# - Runtime logs  
# - Error messages
```