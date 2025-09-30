# 🚀 Deploy no Render.com

Guia completo para deploy da stack n8n + Evolution API no Render.com com PostgreSQL e Redis gerenciados.

## 📋 Pré-requisitos

- Repositório no GitHub
- Conta no [Render.com](https://render.com/)
- Código pronto para produção

## 🏗️ Arquitetura de Deploy

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Web Service   │    │   PostgreSQL    │    │     Redis       │
│      n8n        │◄───┤    Database     │    │     Cache       │
│   (Dockerfile)  │    │   (Gerenciado)  │    │  (Gerenciado)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔧 Passo a Passo

### 1. Criar PostgreSQL Database

**Primeiro**, crie o banco de dados:

- Acesse o dashboard do Render
- Clique em **"New PostgreSQL"**
- Configure:
  - **Name**: `n8n-database`
  - **Database Name**: `n8n_db`
  - **User**: `n8n_user`
  - **Region**: `Oregon (US West)`
  - **Plan**: `Free`

📝 **Anote** os dados de conexão gerados:
- Host, Port, Database, Username, Password
- `DATABASE_URL` (formato completo)

### 2. Criar Web Service

- No dashboard, clique em **"New Web Service"**
- Conecte seu repositório GitHub
- Configure:
  - **Name**: `n8n-app`
  - **Environment**: `Docker`
  - **Dockerfile Path**: `Dockerfile` (arquivo raiz)
  - **Build Command**: deixar vazio
  - **Start Command**: deixar vazio

### 3. Configurar Variáveis de Ambiente

No **Environment** do Web Service, adicione:

#### ✅ Variáveis Obrigatórias
```bash
NODE_ENV=production
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=sua_senha_super_segura_123
```

#### 🗄️ Configuração de Banco de Dados

```bash
# OPÇÃO 1: Apenas DATABASE_URL (mais simples)
DATABASE_URL=postgresql://username:password@hostname:port/database

# OPÇÃO 2: Variáveis individuais (se necessário)
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=hostname_do_postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_USER=username_do_postgres
DB_POSTGRESDB_PASSWORD=password_do_postgres
DB_POSTGRESDB_DATABASE=nome_do_database
```

> ⚠️ **IMPORTANTE**: Use APENAS a `DATABASE_URL` ou as variáveis individuais, não ambas!

#### ⚙️ Configurações do n8n
```bash
N8N_LOG_LEVEL=info
N8N_COMMUNITY_PACKAGES=n8n-nodes-evolution-api
N8N_METRICS=true
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false
N8N_BLOCK_ENV_ACCESS_IN_NODE=false
N8N_DEFAULT_TIMEZONE=America/Recife
```

### 4. Deploy!

- Clique em **"Create Web Service"**
- Aguarde o build completar (5-10 min)
- Sua URL será: `https://n8n-app.onrender.com`

## 🔗 URLs Importantes

Após o deploy bem-sucedido:

- **n8n Interface**: `https://seu-app.onrender.com`
- **Health Check**: `https://seu-app.onrender.com/healthz`
- **Webhook URL**: `https://seu-app.onrender.com/webhook-test/messages-upsert`

## 📱 Configuração do WhatsApp (Evolution API)

### Opção 1: Evolution API no Render
Se quiser hospedar a Evolution API também no Render:

1. **Criar outro Web Service**:
   - **Docker Image**: `evoapicloud/evolution-api:latest`
   - **Port**: `8080`

2. **Variáveis de Ambiente**:
   ```bash
   AUTHENTICATION_API_KEY=CqSRI6BrIlz45prK3KcLNjBTf+/moPvesMRCYYX5LGQ=
   DATABASE_URL=postgresql://... (mesmo banco)
   REDIS_URL=redis://... (se usar Redis)
   ```

### Opção 2: Evolution API Externa
Se usar Evolution API externa, configure o webhook:

```bash
curl -X POST "https://sua-evolution-api.com/webhook/set/instancia" \
  -H "apikey: SUA_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "webhook": {
      "url": "https://seu-app.onrender.com/webhook-test/messages-upsert",
      "events": ["MESSAGES_UPSERT"],
      "enabled": true
    }
  }'
```

## 🧪 Verificação e Testes

### Health Check
```bash
curl https://seu-app.onrender.com/healthz
```

### Acessar Interface
- URL: `https://seu-app.onrender.com`
- User: `admin` (ou configurado)
- Password: sua senha configurada

### Logs de Deploy
No dashboard do Render:
- **Deploy** → Ver logs de build
- **Logs** → Ver logs de runtime
- **Events** → Ver eventos do serviço

## 🐛 Troubleshooting

### ❌ Build Falhando
```bash
# Verificar:
1. Dockerfile existe na raiz do projeto
2. Variáveis de ambiente configuradas
3. Sintaxe do Dockerfile correta
```

### ❌ n8n Não Inicia
```bash
# Verificar:
1. DATABASE_URL configurada corretamente
2. Senha do n8n definida (N8N_BASIC_AUTH_PASSWORD)
3. Logs de inicialização no dashboard
```

### ❌ Conexão com Banco
```bash
# Verificar:
1. PostgreSQL criado e ativo
2. Credenciais corretas nas variáveis
3. Formato da DATABASE_URL
```

### ❌ Performance Lenta
```bash
# Para melhorar:
1. Upgrade para plano pago
2. Otimizar queries do banco
3. Usar Redis para cache
```

## 💡 Configuração Simplificada Recomendada

Para evitar erros, use **APENAS** estas variáveis no Render:

```bash
# ✅ BÁSICAS - OBRIGATÓRIAS
NODE_ENV=production
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=sua_senha_super_segura_123

# ✅ BANCO - USE APENAS DATABASE_URL (copiada do PostgreSQL)
DATABASE_URL=postgresql://n8n_user:abcd1234567890@dpg-abc123-a.oregon-postgres.render.com:5432/n8n_db_xyz

# ✅ OPCIONAL - CONFIGURAÇÕES EXTRAS
N8N_LOG_LEVEL=info
N8N_COMMUNITY_PACKAGES=n8n-nodes-evolution-api
N8N_METRICS=true
N8N_DEFAULT_TIMEZONE=America/Recife
```

> ⚠️ **CRÍTICO**: 
> - **NÃO** configure `DB_TYPE=postgresdb` quando usar `DATABASE_URL`
> - **NÃO** configure variáveis individuais (`DB_POSTGRESDB_*`)  
> - **Use APENAS** a `DATABASE_URL` que o Render gera automaticamente

## 🔄 Deploy Automático

O Render pode fazer deploy automático:
- A cada push na branch `main`
- Configure em **Settings** → **Auto-Deploy**

## 📊 Monitoramento

- **Metrics**: Ativar no dashboard do Render
- **Health Checks**: `/healthz` endpoint
- **Logs**: Centralizados no dashboard
- **Alerts**: Configurar notificações

---

**🎉 Pronto!** Sua stack n8n está rodando em produção no Render.com.

---

# 🔧 Configuração Rápida no Render.com

## 📋 **Passo a Passo Simplificado**

### 1. **Criar PostgreSQL Database**
- Dashboard Render → **New PostgreSQL**
- Name: `n8n-database`
- Plan: **Free**

### 2. **Configurar Web Service**
No **Environment** do seu Web Service, adicione **APENAS**:

```bash
NODE_ENV=production
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=sua_senha_super_segura_123
DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DATABASE}
N8N_COMMUNITY_PACKAGES=n8n-nodes-evolution-api
N8N_COMMUNITY_PACKAGES_ENABLED=true
```

### 3. **Conectar Banco**
- Web Service → **Environment** → **Link Database**
- Selecionar PostgreSQL criado

### 4. **Deploy Manual**
- **Deploy Latest Commit**
- Aguardar 5-10 minutos

---

# 🚨 Troubleshooting

## ❌ **Problemas Comuns**

### **Error: Command not found**
- Verificar Dockerfile
- Usar comando correto: `n8n start`

### **Database connection failed**
- Verificar DATABASE_URL
- Remover variáveis `DB_POSTGRESDB_*`

### **Evolution API nodes missing**
- Verificar `N8N_COMMUNITY_PACKAGES=n8n-nodes-evolution-api`
- Aguardar instalação do pacote

### **Build failing**
- Verificar logs no dashboard
- Confirmar Dockerfile na raiz

## ✅ **Checklist de Verificação**
- [ ] PostgreSQL Database criado
- [ ] DATABASE_URL configurada
- [ ] N8N_COMMUNITY_PACKAGES configurado
- [ ] Build sem erros
- [ ] n8n acessível na URL

---

# 🔗 Evolution API Setup

## **URLs Importantes:**
- **n8n**: `https://seu-app.onrender.com`
- **Evolution API**: Precisa ser deployada separadamente

## **Como Verificar Evolution Nodes:**
1. Acessar n8n
2. Criar novo workflow
3. Procurar "Evolution" nos nós
4. Confirmar presença dos nós Evolution API

## **Configurar Webhook:**
```bash
# URL para webhook da Evolution API
https://seu-n8n.onrender.com/webhook-test/messages-upsert
```