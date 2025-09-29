# Dockerfile para produção (Render.com)
FROM node:18-alpine

WORKDIR /app

# Instalar dependências do sistema
RUN apk add --no-cache curl wget postgresql-client redis

# Copiar arquivos de configuração
COPY package*.json ./
COPY docker-compose.prod.yml ./docker-compose.yml
COPY .env.prod ./.env

# Instalar dependências se houver package.json
RUN if [ -f package.json ]; then npm install; fi

# Copiar scripts
COPY scripts/ ./scripts/

# Expor portas
EXPOSE 5678 8080 5432 6379

# Comando para iniciar os serviços
CMD ["sh", "-c", "echo 'Iniciando serviços...' && sleep infinity"]