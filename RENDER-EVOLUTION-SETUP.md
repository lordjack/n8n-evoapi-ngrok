# 🚀 **Deploy n8n + Evolution API no Render.com**

Este guia mostra como configurar tanto n8n quanto Evolution API no Render.com usando **Container Único** (abordagem simplificada).

## 📋 **Pré-requisitos**

1. Conta no [Render.com](https://render.com)
2. Repositório GitHub atualizado
3. PostgreSQL e Redis configurados no Render

---

## 🎯 **Configuração Container Único (Recomendada)**

### **1. Configurar Banco de Dados no Render**

**PostgreSQL:**
```bash
# No Render Dashboard
New → PostgreSQL
Name: n8n-evolution-postgres
Database Name: n8n_evolution_db
User: app_user
```

**Redis:**
```bash
# No Render Dashboard  
New → Redis
Name: n8n-evolution-redis
```

### **2. Deploy do Container Único**

```bash
# No Render Dashboard
New → Web Service
Repository: seu-repositorio-github
Branch: main
Dockerfile Path: ./Dockerfile
```

### **3. Configurar Variáveis de Ambiente Obrigatórias:**

No Dashboard do Render → Environment:

```bash
# === OBRIGATÓRIAS ===
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=sua_senha_super_secreta_123
AUTHENTICATION_API_KEY=sua_chave_evolution_api_super_secreta_123

# === PERSISTÊNCIA (automático - conectar bancos) ===
DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DATABASE}
REDIS_URL=${REDIS_URL}

# === CONFIGURAÇÕES DE PERSISTÊNCIA ===
DB_TYPE=postgresdb
N8N_ENCRYPTION_KEY=chave_criptografia_workflows_super_secreta_123
CACHE_REDIS_SAVE_INSTANCES=true
```

**⚠️ IMPORTANTE PARA PLANO GRATUITO:**
- ✅ **Todos os dados serão salvos no PostgreSQL** (workflows, instâncias WhatsApp)
- ✅ **Cache no Redis** (sessões temporárias)
- ❌ **SEM volumes locais** (dados persistem mesmo com restart)
- 📖 **Consulte:** `PERSISTENCIA-DADOS.md` para detalhes

### **4. URLs de Acesso:**

Após o deploy, você terá:

```bash
# N8N (porta principal - 5678)
https://seu-app.onrender.com

# Evolution API (porta 8080)
https://seu-app.onrender.com:8080

# Evolution API Manager
https://seu-app.onrender.com:8080/manager

# Evolution API Docs
https://seu-app.onrender.com:8080/docs
```

---

## ⚙️ **Configuração Completa das Variáveis**

### **Variáveis Obrigatórias:**
```bash
NODE_ENV=production
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=sua_senha_forte_123
AUTHENTICATION_API_KEY=chave_evolution_api_123
```

### **Variáveis Automáticas do Render:**
```bash
# Estas são preenchidas automaticamente pelo Render
RENDER_EXTERNAL_HOSTNAME=seu-app.onrender.com
POSTGRES_HOST=host-automatico
POSTGRES_PORT=5432
POSTGRES_USER=usuario-automatico  
POSTGRES_PASSWORD=senha-automatica
POSTGRES_DATABASE=db-automatico
REDIS_URL=redis://usuario:senha@host:porto
```

---

## 🔧 **Como Conectar n8n com Evolution API**

### **1. URLs para usar no n8n:**

```bash
# Evolution API Base URL
http://localhost:8080

# Ou externamente (se necessário)
https://seu-app.onrender.com:8080
```

### **2. Headers de Autenticação:**

```bash
apikey: sua_chave_evolution_api_123
```

### **3. Endpoints Principais da Evolution API:**

```bash
# Criar instância WhatsApp
POST http://localhost:8080/instance/create
Body: {
  "instanceName": "minha_instancia",
  "qrcode": true,
  "integration": "WHATSAPP-BAILEYS"
}

# Status da instância  
GET http://localhost:8080/instance/status/minha_instancia

# QR Code para conectar WhatsApp
GET http://localhost:8080/instance/qrcode/minha_instancia

# Enviar mensagem
POST http://localhost:8080/message/sendText/minha_instancia
Body: {
  "number": "5511999999999",
  "text": "Olá! Esta é uma mensagem de teste."
}
```

---

## 🧪 **Teste da Configuração**

### **1. Verificar se o container está rodando:**
```bash
# Acesse o n8n
https://seu-app.onrender.com

# Acesse a Evolution API
https://seu-app.onrender.com:8080
```

### **2. Teste via API:**
```bash
# Verificar Evolution API
curl https://seu-app.onrender.com:8080 \
  -H "apikey: sua_chave_evolution_api_123"

# Criar instância de teste
curl -X POST https://seu-app.onrender.com:8080/instance/create \
  -H "apikey: sua_chave_evolution_api_123" \
  -H "Content-Type: application/json" \
  -d '{"instanceName": "teste", "qrcode": true}'
```

### **3. Configurar Workflow no n8n:**

1. **Acesse:** `https://seu-app.onrender.com`
2. **Login:** Use as credenciais configuradas
3. **Crie novo workflow**
4. **Adicione nó HTTP Request:**
   - URL: `http://localhost:8080/instance/create`
   - Method: POST
   - Headers: `apikey: sua_chave_evolution_api`
   - Body: `{"instanceName": "workflow_test", "qrcode": true}`

---

## ⚠️ **Troubleshooting**

### **Erro: Evolution API não responde**
```bash
# Verificar logs no Render Dashboard
# Logs → Web Service → Ver logs em tempo real

# Verificar se as portas estão expostas
# O container expõe 5678 (n8n) e 8080 (Evolution API)
```

### **Erro: n8n não conecta na Evolution API**
```bash
# Use URL interna: http://localhost:8080
# Não use https:// para comunicação interna
# Verificar se AUTHENTICATION_API_KEY está configurado
```

### **Erro: Banco de dados não conecta**
```bash
# Verificar se PostgreSQL está conectado ao Web Service
# Verificar variável DATABASE_URL
# Exemplo correto:
# postgresql://user:pass@host:5432/database
```

### **Erro: Evolution nodes não carregam no n8n**
```bash
# Verificar se estas variáveis estão configuradas:
N8N_COMMUNITY_PACKAGES=n8n-nodes-evolution-api
N8N_COMMUNITY_PACKAGES_ENABLED=true

# Se persistir, verificar logs de build no Render
```

---

## 🎉 **Próximos Passos**

1. **Configure webhooks** da Evolution API para o n8n
2. **Crie workflows** de automação WhatsApp
3. **Configure instâncias** WhatsApp via Evolution API Manager
4. **Monitore logs** no Dashboard do Render

### **URLs Finais:**

- 🎯 **n8n:** `https://seu-app.onrender.com`
- 🔗 **Evolution API:** `https://seu-app.onrender.com:8080`
- 📱 **Manager:** `https://seu-app.onrender.com:8080/manager`
- 📚 **Docs:** `https://seu-app.onrender.com:8080/docs`

---

## 📚 **Links Úteis**

- [Render.com Documentation](https://render.com/docs)
- [Evolution API Documentation](https://doc.evolution-api.com)
- [n8n Community Nodes](https://docs.n8n.io/integrations/community-nodes/)
- [n8n Evolution API Nodes](https://www.npmjs.com/package/n8n-nodes-evolution-api)

### **1. Modificar Dockerfile**

```bash
# Renomear o Dockerfile atual
mv Dockerfile Dockerfile.n8n-only
mv Dockerfile.multi Dockerfile
```

### **2. Deploy no Render**

```bash
# No Render Dashboard
New → Web Service
Repository: seu-repo
Dockerfile Path: ./Dockerfile
```

### **3. Configurar Variáveis de Ambiente:**

```bash
# N8N
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=sua_senha_super_secreta
DATABASE_URL=postgresql://user:pass@host:port/db

# Evolution API
AUTHENTICATION_API_KEY=sua_chave_evolution_api_123
REDIS_URL=redis://user:pass@host:port
```

### **4. URLs de Acesso (Container Único):**

```bash
# N8N (porta principal do serviço)
https://seu-app.onrender.com

# Evolution API (mesmo domínio, porta 8080)
https://seu-app.onrender.com:8080

# Evolution API Manager
https://seu-app.onrender.com:8080/manager

# Evolution API Docs
https://seu-app.onrender.com:8080/docs
```

---

## ⚙️ **Configuração Detalhada**

### **Variáveis de Ambiente Obrigatórias:**

```bash
# === N8N ===
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=senha_forte_123
DATABASE_URL=postgresql://...

# === EVOLUTION API ===
AUTHENTICATION_API_KEY=chave_api_evolution_123
DATABASE_CONNECTION_URI=postgresql://...
CACHE_REDIS_URI=redis://...
```

### **URLs Automáticas do Render:**

O Render.com fornece automaticamente:
```bash
RENDER_EXTERNAL_HOSTNAME=seu-app.onrender.com
POSTGRES_HOST=host-automatico
POSTGRES_PORT=5432
POSTGRES_USER=usuario-automatico  
POSTGRES_PASSWORD=senha-automatica
POSTGRES_DATABASE=db-automatico
```

---

## 🔧 **Como Conectar n8n com Evolution API**

### **1. No n8n, usar estas URLs:**

**Para Serviços Separados:**
```bash
Evolution API URL: https://evolution-api-production.onrender.com
```

**Para Container Único:**
```bash
Evolution API URL: http://localhost:8080
```

### **2. Headers de Autenticação:**

```bash
apikey: sua_chave_evolution_api_123
```

### **3. Endpoints Principais:**

```bash
# Criar instância
POST /instance/create

# Status da instância  
GET /instance/status/{instance}

# Enviar mensagem
POST /message/sendText/{instance}

# QR Code
GET /instance/qrcode/{instance}
```

---

## 🧪 **Teste da Configuração**

### **1. Verificar n8n:**
```bash
curl https://seu-app.onrender.com/healthz
```

### **2. Verificar Evolution API:**
```bash
curl https://evolution-api-production.onrender.com/ \
  -H "apikey: sua_chave_api"
```

### **3. Testar Comunicação:**
No n8n, criar workflow simples:
1. HTTP Request para Evolution API
2. Verificar resposta da API

---

## ⚠️ **Troubleshooting**

### **Erro: Evolution API não conecta**
```bash
# Verificar se as URLs estão corretas
# Verificar se a chave API está configurada
# Verificar logs no Render Dashboard
```

### **Erro: n8n não encontra Evolution nodes**
```bash
# Verificar se N8N_COMMUNITY_PACKAGES está configurado
# Forçar reinstalação: 
CMD ["sh", "-c", "npm install -g n8n-nodes-evolution-api; n8n start"]
```

### **Erro: Banco de dados não conecta**
```bash
# Verificar DATABASE_URL
# Usar variáveis automáticas do Render:
postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DATABASE}
```

---

## 🎉 **Próximos Passos**

1. **Configure webhooks** para receber mensagens do WhatsApp
2. **Crie workflows** no n8n para automação
3. **Configure instâncias** do WhatsApp via Evolution API
4. **Monitore logs** no Dashboard do Render

### **URLs Finais de Acesso:**

**Abordagem 1 (Serviços Separados):**
- 🎯 N8N: `https://n8n-production.onrender.com`
- 🔗 Evolution API: `https://evolution-api-production.onrender.com`
- 📱 Manager: `https://evolution-api-production.onrender.com/manager`

**Abordagem 2 (Container Único):**
- 🎯 N8N: `https://seu-app.onrender.com`
- 🔗 Evolution API: `https://seu-app.onrender.com:8080`
- 📱 Manager: `https://seu-app.onrender.com:8080/manager`

---

## 📚 **Documentação Adicional**

- [Render.com Docs](https://render.com/docs)
- [Evolution API Docs](https://doc.evolution-api.com)
- [n8n Community Nodes](https://docs.n8n.io/integrations/community-nodes/)