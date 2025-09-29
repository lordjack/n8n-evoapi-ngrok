# Configuração para Render.com - Variáveis de Ambiente

## ✅ **Variáveis OBRIGATÓRIAS no Render Dashboard**

### Configurações Básicas:
```bash
NODE_ENV=production
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=sua_senha_super_segura_123
```

### Configurações de Banco (quando criar PostgreSQL):
```bash
# O Render irá gerar automaticamente DATABASE_URL
# Mas você precisa configurar estas também:
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=${POSTGRES_HOST}
DB_POSTGRESDB_PORT=${POSTGRES_PORT}
DB_POSTGRESDB_USER=${POSTGRES_USER}
DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
DB_POSTGRESDB_DATABASE=${POSTGRES_DATABASE}
```

### Configurações do n8n:
```bash
N8N_LOG_LEVEL=info
N8N_COMMUNITY_PACKAGES=n8n-nodes-evolution-api
N8N_METRICS=true
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false
N8N_BLOCK_ENV_ACCESS_IN_NODE=false
N8N_DEFAULT_TIMEZONE=America/Recife
```

---

## 🎯 **Passo a Passo no Render**

### 1. **Criar PostgreSQL Database PRIMEIRO**
- Nome: `n8n-database`
- Região: `Oregon (US West)`
- Plano: `Free`
- **ANOTAR**: Hostname, Port, Database Name, Username, Password

### 2. **Criar Web Service**
- **Runtime**: `Docker`
- **Build Command**: deixar vazio
- **Start Command**: `/usr/local/bin/start-n8n.sh`

### 3. **Configurar Variáveis de Ambiente**
Use os dados do PostgreSQL criado no passo 1:

```bash
# Básicas
NODE_ENV=production
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=MinhaSenh@Segur@123

# Banco (usar dados do PostgreSQL criado)
DATABASE_URL=postgresql://username:password@hostname:port/database
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=hostname_do_postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_USER=username_do_postgres
DB_POSTGRESDB_PASSWORD=password_do_postgres
DB_POSTGRESDB_DATABASE=nome_do_database

# n8n
N8N_LOG_LEVEL=info
N8N_COMMUNITY_PACKAGES=n8n-nodes-evolution-api
N8N_METRICS=true
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false
N8N_BLOCK_ENV_ACCESS_IN_NODE=false
N8N_DEFAULT_TIMEZONE=America/Recife
```

---

## 🔧 **Exemplo de Configuração Completa**

Se o PostgreSQL criado tiver estes dados:
- **Host**: `dpg-abc123-a.oregon-postgres.render.com`
- **Port**: `5432`
- **Database**: `n8n_db_xyz`
- **Username**: `n8n_user`
- **Password**: `abcd1234567890`

Então configure assim no Web Service:

```bash
DATABASE_URL=postgresql://n8n_user:abcd1234567890@dpg-abc123-a.oregon-postgres.render.com:5432/n8n_db_xyz
DB_POSTGRESDB_HOST=dpg-abc123-a.oregon-postgres.render.com
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_USER=n8n_user
DB_POSTGRESDB_PASSWORD=abcd1234567890
DB_POSTGRESDB_DATABASE=n8n_db_xyz
```