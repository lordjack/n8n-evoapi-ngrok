# Automação n8n + Evolution API + WhatsApp

Stack completa para automação de mensagens WhatsApp usando **n8n**, **Evolution API**, **PostgreSQL**, **Redis** e **Ngrok**.

## 🚀 Quick Start

### 💻 Desenvolvimento Local
```bash
# 1. Clone o repositório
git clone https://github.com/seu-usuario/n8n-evoapi-ngrok.git
cd n8n-evoapi-ngrok

# 2. Configure as variáveis
cp .env.example .env
# Edite o .env com suas configurações

# 3. Inicie os serviços
docker-compose up -d

# 4. Acesse os serviços
# n8n: http://localhost:5678
# Evolution API: http://localhost:8080  
# Adminer: http://localhost:8081
# ngrok dashboard: http://localhost:4040
```

### ☁️ Deploy em Produção
👉 **[Ver guia completo de deploy](./DEPLOY.md)**

## 📋 Pré-requisitos

- [Docker](https://docs.docker.com/get-docker/) e [Docker Compose](https://docs.docker.com/compose/install/)
- Conta no [Ngrok](https://ngrok.com/) (para desenvolvimento)
- Conta no [Render.com](https://render.com/) (para produção)

## ⚙️ Configuração Local

### 1. Configurar ngrok
- Obtenha seu authtoken em [ngrok.com](https://ngrok.com/)
- Edite `ngrok.yml` com seu token

### 2. Configurar variáveis de ambiente
Crie/edite o arquivo `.env`:

```env
# PostgreSQL
POSTGRES_USER=postgres
POSTGRES_PASSWORD=senha_postgres
POSTGRES_DB=app_db

# n8n
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=sua_senha
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_USER=${POSTGRES_USER}
DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
DB_POSTGRESDB_DATABASE=${POSTGRES_DB}

# Evolution API
AUTHENTICATION_API_KEY=sua_key_segura
DATABASE_ENABLED=true
DATABASE_PROVIDER=postgresql
DATABASE_CONNECTION_URI=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@postgres:5432/${POSTGRES_DB}

# Redis
CACHE_REDIS_ENABLED=true
CACHE_REDIS_URI=redis://redis:6379/6

# ngrok (obter em ngrok.com)
NGROK_AUTHTOKEN=seu_token_aqui
```

### 3. Gerenciar serviços

```bash
# Desenvolvimento local
docker-compose up -d        # ou npm run dev
docker-compose logs -f      # ou npm run dev:logs  
docker-compose down         # ou npm run dev:down

# Produção auto-hospedada
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d  # ou npm run prod
npm run prod:logs
npm run prod:down
npm run prod:clean          # limpar volumes
```

## 🔗 URLs e Acessos

### Desenvolvimento Local
- **n8n**: http://localhost:5678 (user/senha do .env)
- **Evolution API**: http://localhost:8080
- **Adminer**: http://localhost:8081 (postgres/postgres/app_db)
- **ngrok dashboard**: http://localhost:4040
- **URL pública n8n**: Veja no dashboard do ngrok

### Webhooks
A URL pública do n8n muda a cada restart do ngrok. Sempre configure webhooks com a nova URL obtida em http://localhost:4040.

## 📦 Serviços Incluídos

- **n8n**: Automação de workflows
- **Evolution API**: API WhatsApp
- **PostgreSQL**: Banco de dados principal
- **Redis**: Cache para Evolution API  
- **ngrok**: Túnel público para desenvolvimento
- **Adminer**: Interface web para PostgreSQL

## 🚀 Deploy em Produção

Para deploy em produção no Render.com, consulte o **[Guia de Deploy](./DEPLOY.md)** com instruções detalhadas.

## 🤝 Contribuição

Contribuições são bem-vindas! Abra issues ou envie pull requests.

## 📄 Licença

Este projeto está sob a licença [MIT](LICENSE).
