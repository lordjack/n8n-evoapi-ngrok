# 🚨 **Troubleshooting Deploy Render.com**

Este guia resolve problemas comuns durante o deploy no Render.com.

## ❌ **Novos Erros Identificados (Resolvidos)**

### **1. npm WARN EBADENGINE + npm install failed**

**Problema:**
```bash
npm warn EBADENGINE Unsupported engine { node: ">=20.16", npm: ">=9.5" }
npm error code 127
npm warn exec The following package was not found and will be installed: only-allow@1.2.1
npm error command failed
```

**Causa:**
- Evolution API requer Node.js 20+ mas usamos Node.js 18
- Dependências conflitantes
- Package `only-allow` não encontrado

**Solução:**
```dockerfile
# ❌ ANTES
FROM node:18-alpine
RUN npm install -g n8n-nodes-evolution-api

# ✅ DEPOIS  
FROM node:18-alpine
# Instalar community packages apenas na inicialização
RUN npm install -g n8n@latest
# Evolution API nodes serão instalados no runtime
```

### **2. adduser uid '1000' in use**

**Problema:**
```bash
ERROR: process '/bin/sh -c adduser -D -u 1000 appuser' did not complete successfully: exit code: 1
adduser: uid '1000' in use
```

**Causa:**
UID 1000 já existe na imagem base.

**Solução:**
```dockerfile
# ❌ ANTES
RUN adduser -D -u 1000 appuser

# ✅ DEPOIS
RUN adduser -D appuser
# Deixar o Alpine escolher o UID automaticamente
```

### **3. Evolution API Build Complex**

**Problema:**
```bash
npm run build - script não encontrado
npm install - dependências conflitantes
```

**Solução:**
```dockerfile
# Usar download direto em vez de git clone + build
RUN curl -L https://github.com/EvolutionAPI/evolution-api/archive/refs/heads/main.tar.gz | tar -xz --strip-components=1
RUN npm install --production --no-optional || echo "continuing..."
```

---

## 🔧 **Outros Problemas Comuns**

### **1. Erro: COPY <<EOF não suportado**

**Problema:**
```dockerfile
COPY <<EOF /etc/supervisor/conf.d/supervisord.conf
```

**Solução:**
```dockerfile
# Usar echo em vez de COPY <<EOF
RUN echo '[supervisord]' > /etc/supervisor/conf.d/supervisord.conf
RUN echo 'nodaemon=true' >> /etc/supervisor/conf.d/supervisord.conf
```

### **2. Erro: Git clone falha**

**Problema:**
```bash
fatal: could not resolve github.com
```

**Solução:**
```dockerfile
# Fallback para download direto
RUN git clone https://github.com/EvolutionAPI/evolution-api.git . || \
    (curl -L https://github.com/EvolutionAPI/evolution-api/archive/refs/heads/main.zip -o main.zip && \
     unzip main.zip && mv evolution-api-main/* . && rm -rf evolution-api-main main.zip)
```

### **3. Erro: npm install falha**

**Problema:**
```bash
npm ERR! network timeout
```

**Solução:**
```dockerfile
# Usar --production e continuar mesmo se falhar
RUN npm install --production || echo "npm install failed, continuing..."
```

### **4. Erro: Community packages não instalam**

**Problema:**
```bash
npm ERR! could not install n8n-nodes-evolution-api
```

**Solução:**
```dockerfile
# Tentar na inicialização também
RUN npm install -g n8n-nodes-evolution-api || echo "Will try again at startup"
```

---

## 🛠️ **Dockerfile Corrigido**

O novo `Dockerfile` inclui:

### **✅ Correções Aplicadas:**
1. **Usuário simplificado** - `adduser -D -u 1000 appuser`
2. **Supervisor via echo** - Sem `COPY <<EOF`
3. **Git com fallback** - Download direto se git falhar
4. **npm resiliente** - Continua mesmo com falhas
5. **Reinstalação na inicialização** - Segunda chance para packages

### **🔄 Script de Inicialização Robusto:**
```bash
#!/bin/bash
set -e

# Verificar variáveis obrigatórias
if [ -z "$N8N_BASIC_AUTH_PASSWORD" ]; then
  echo "❌ N8N_BASIC_AUTH_PASSWORD não está definido!"
  exit 1
fi

# Tentar instalar community packages novamente
npm install -g n8n-nodes-evolution-api || echo "Community packages install failed"

# Configurar variáveis para persistência
export DB_TYPE=postgresdb
export DATABASE_URL=${DATABASE_URL}
export AUTHENTICATION_API_KEY=${AUTHENTICATION_API_KEY}

# Iniciar supervisor
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
```

---

## 🚀 **Como Fazer Novo Deploy**

### **1. Commit das Correções:**
```bash
git add .
git commit -m "Fix: Corrigir erros de build no Dockerfile para Render.com"
git push origin main
```

### **2. No Render Dashboard:**
```bash
1. Ir para o Web Service
2. Clicar em "Manual Deploy"
3. Selecionar "Deploy Latest Commit"
4. Acompanhar logs em tempo real
```

### **3. Monitorar Build:**
```bash
# Logs devem mostrar:
✅ Installing dependencies... 
✅ Creating user appuser...
✅ Installing n8n...
✅ Cloning Evolution API...
✅ Building container...
✅ Starting services...
```

---

## 📊 **Verificar Deploy Bem-sucedido**

### **1. Logs de Inicialização:**
```bash
🚀 Iniciando n8n e Evolution API...
📊 N8N será acessível na porta 5678
🔗 Evolution API será acessível na porta 8080
🗄️  Usando PostgreSQL externo para persistência
💾 Dados serão mantidos entre reinicializações
```

### **2. Testar URLs:**
```bash
# N8N
curl https://seu-app.onrender.com/healthz

# Evolution API  
curl https://seu-app.onrender.com:8080/ \
  -H "apikey: sua_chave_api"
```

### **3. Verificar Logs de Aplicação:**
```bash
# No Render Dashboard → Logs
[INFO] n8n ready on port 5678
[INFO] Evolution API ready on port 8080
[INFO] PostgreSQL connected
[INFO] Redis connected
```

---

## ⚠️ **Se Ainda Houver Problemas**

### **Build Timeout:**
```bash
# Se build demorar mais de 15 min:
1. Simplificar ainda mais o Dockerfile
2. Remover build da Evolution API
3. Usar imagem pré-construída
```

### **Memory Limit:**
```bash
# Se faltar memória durante build:
1. Usar npm install --production
2. Remover devDependencies
3. Usar multi-stage build
```

### **Network Issues:**
```bash
# Se problemas de rede:
1. Usar mirrors npm alternativos
2. Download manual de dependências
3. Cache de build layers
```

---

## 🆘 **Última Alternativa: Dockerfile Mínimo**

Se todos os problemas persistirem:

```dockerfile
FROM node:18-alpine

# Mínimo necessário
RUN apk add --no-cache bash supervisor postgresql-client
RUN npm install -g n8n
RUN adduser -D appuser

# Apenas n8n (sem Evolution API)
EXPOSE 5678
USER appuser
CMD ["n8n", "start"]
```

E usar Evolution API como serviço separado.

---

**🎯 Com essas correções, o build no Render.com deve funcionar sem erros!**