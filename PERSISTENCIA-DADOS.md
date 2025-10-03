# 💾 **Persistência de Dados no Render.com (Plano Gratuito)**

Este guia explica como configurar persistência de dados para n8n e Evolution API no plano gratuito do Render.com, onde o armazenamento local é efêmero.

## ⚠️ **Problema do Plano Gratuito**

No plano gratuito do Render.com:
- ❌ **Armazenamento local é efêmero** - dados são perdidos quando o container é reiniciado
- ❌ **Volumes não persistem** - sem volumes persistentes
- ❌ **Arquivos locais são temporários** - perdidos a cada deploy

## ✅ **Solução: Bancos Externos**

Nossa solução usa **apenas bancos de dados externos** para persistência:
- 🗄️ **PostgreSQL** - Workflows n8n, instâncias WhatsApp, mensagens
- 🔄 **Redis** - Cache, sessões temporárias
- 🚫 **SEM volumes locais** - tudo no banco

---

## 🗄️ **O que é Persistido**

### **N8N (no PostgreSQL):**
- ✅ Workflows e automações
- ✅ Credenciais (criptografadas)
- ✅ Histórico de execuções
- ✅ Configurações do sistema
- ✅ Webhooks configurados

### **Evolution API (no PostgreSQL):**
- ✅ Instâncias do WhatsApp
- ✅ Sessões de conexão
- ✅ Mensagens enviadas/recebidas
- ✅ Contatos e grupos
- ✅ Configurações das instâncias

### **Cache (no Redis):**
- 🔄 Sessões temporárias
- 🔄 Cache de performance
- 🔄 Estado de conexão

---

## ⚙️ **Configuração no Render**

### **1. Criar Bancos de Dados**

**PostgreSQL:**
```bash
Dashboard Render → New → PostgreSQL
Name: n8n-evolution-postgres
Database Name: app_db
Plan: Free (100MB)
```

**Redis:**
```bash
Dashboard Render → New → Redis  
Name: n8n-evolution-redis
Plan: Free (25MB)
```

### **2. Conectar ao Web Service**

```bash
Dashboard Render → Web Service → Environment
Conectar PostgreSQL: Adicionar DATABASE_URL
Conectar Redis: Adicionar REDIS_URL
```

### **3. Variáveis de Ambiente Obrigatórias**

```bash
# === AUTENTICAÇÃO ===
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=sua_senha_forte_123
AUTHENTICATION_API_KEY=sua_chave_evolution_123

# === PERSISTÊNCIA (automáticas) ===
DATABASE_URL=${DATABASE_URL}
REDIS_URL=${REDIS_URL}

# === CONFIGURAÇÕES DE PERSISTÊNCIA ===
DB_TYPE=postgresdb
CACHE_REDIS_ENABLED=true
CACHE_REDIS_SAVE_INSTANCES=true
N8N_ENCRYPTION_KEY=chave_criptografia_workflows_123
```

---

## 🔄 **Backup e Restore**

### **Script Automático de Backup**

```bash
# Dentro do container Render
/app/scripts/backup-restore.sh backup
```

### **Como Fazer Backup Manual**

```bash
# 1. Conectar ao container via SSH (se disponível)
# 2. Executar backup
pg_dump $DATABASE_URL > backup.sql

# 3. Baixar backup (antes do restart)
curl -o backup.sql http://seu-app.onrender.com/backup.sql
```

### **Como Restaurar Backup**

```bash
# 1. Upload do arquivo backup.sql
# 2. Restaurar no banco
psql $DATABASE_URL < backup.sql

# 3. Reiniciar o serviço
# Dashboard Render → Manual Deploy
```

---

## 🧪 **Testando a Persistência**

### **1. Criar Dados de Teste**

**No n8n:**
1. Criar um workflow simples
2. Configurar credenciais de teste
3. Executar o workflow

**Na Evolution API:**
1. Criar uma instância WhatsApp
2. Conectar via QR Code
3. Enviar mensagens de teste

### **2. Forçar Restart**

```bash
# No Dashboard Render
Manual Deploy → Deploy Latest Commit
```

### **3. Verificar Dados**

```bash
# Acessar novamente após restart
https://seu-app.onrender.com
https://seu-app.onrender.com:8080/manager

# Verificar se workflows e instâncias persistiram
```

---

## 📊 **Monitoramento de Dados**

### **Verificar Uso do PostgreSQL**

```bash
# No terminal do container
psql $DATABASE_URL -c "
  SELECT 
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
  FROM pg_tables 
  WHERE schemaname NOT IN ('information_schema','pg_catalog')
  ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
"
```

### **Verificar Uso do Redis**

```bash
# Conectar ao Redis
redis-cli -u $REDIS_URL info memory
redis-cli -u $REDIS_URL dbsize
```

---

## ⚠️ **Limitações do Plano Gratuito**

### **PostgreSQL (100MB):**
- ✅ ~10.000 workflows pequenos
- ✅ ~100.000 mensagens WhatsApp
- ✅ ~1.000 instâncias WhatsApp
- ⚠️ Monitorar uso regularmente

### **Redis (25MB):**
- ✅ Cache de 1.000-5.000 sessões
- ✅ Cache de performance
- ⚠️ TTL automático limpa dados antigos

### **Sem Armazenamento de Arquivos:**
- ❌ Não salvar mídias localmente
- ✅ Usar URLs externas (Cloudinary, AWS S3)
- ✅ Referenciar arquivos por URL

---

## 🛠️ **Troubleshooting**

### **Dados Perdidos Após Restart**

```bash
# Verificar se bancos estão conectados
echo $DATABASE_URL
echo $REDIS_URL

# Verificar logs
Dashboard Render → Logs → Ver erros de conexão
```

### **Banco PostgreSQL Cheio**

```bash
# Limpar execuções antigas
psql $DATABASE_URL -c "
  DELETE FROM execution_entity 
  WHERE finished_at < NOW() - INTERVAL '30 days';
"

# Limpar mensagens antigas
psql $DATABASE_URL -c "
  DELETE FROM \"Message\" 
  WHERE created_at < NOW() - INTERVAL '7 days';
"
```

### **Cache Redis Cheio**

```bash
# Limpar cache
redis-cli -u $REDIS_URL FLUSHDB

# Verificar TTL
redis-cli -u $REDIS_URL CONFIG GET maxmemory-policy
```

---

## 📈 **Upgrade para Planos Pagos**

Se precisar de mais espaço:

### **PostgreSQL:**
- **Starter ($7/mês):** 1GB
- **Standard ($20/mês):** 10GB
- **Pro ($90/mês):** 100GB

### **Redis:**
- **Starter ($10/mês):** 100MB
- **Standard ($25/mês):** 1GB

### **Disk Storage:**
- **Volumes persistentes** disponíveis nos planos pagos
- **50GB-1TB** de armazenamento persistente

---

## ✅ **Checklist de Persistência**

- [ ] PostgreSQL criado e conectado
- [ ] Redis criado e conectado  
- [ ] Variáveis DATABASE_URL e REDIS_URL configuradas
- [ ] DB_TYPE=postgresdb definido
- [ ] N8N_ENCRYPTION_KEY configurada
- [ ] CACHE_REDIS_SAVE_INSTANCES=true
- [ ] Teste de persistência realizado
- [ ] Script de backup configurado
- [ ] Monitoramento de uso ativo

---

**🎉 Com essa configuração, seus dados n8n e Evolution API permanecerão seguros mesmo com restarts frequentes no plano gratuito do Render.com!**