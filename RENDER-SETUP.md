# Configuração para Deploy no Render.com

## 📋 Passos para Deploy

### 1. Configurar Variáveis de Ambiente no Render

```bash
# Obrigatórias
N8N_PASSWORD=sua_senha_super_segura
AUTHENTICATION_API_KEY=CqSRI6BrIlz45prK3KcLNjBTf+/moPvesMRCYYX5LGQ=
NODE_ENV=production

# Automáticas (Render)
DATABASE_URL=postgresql://... (criado automaticamente)
REDIS_URL=redis://... (criado automaticamente)
RENDER_EXTERNAL_HOSTNAME=seu-app.onrender.com (automático)
```

### 2. Configurar Serviços no Render

1. **Web Service**:
   - Dockerfile: `Dockerfile.render`
   - Build Command: `echo "Build ready"`
   - Start Command: `n8n start`

2. **PostgreSQL Database**:
   - Plano Free
   - Nome: `n8n-database`

3. **Redis Cache**:
   - Plano Free  
   - Nome: `n8n-redis`

### 3. URLs após Deploy

- n8n: `https://seu-app.onrender.com`
- Health: `https://seu-app.onrender.com/healthz`