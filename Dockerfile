# Dockerfile Multi-Serviço para Render.com (Gratuito)
# Este container executa tanto n8n quanto Evolution API
# CONFIGURADO PARA PERSISTÊNCIA DE DADOS com bancos externos

FROM node:18-alpine

# Instalar dependências do sistema
RUN apk add --no-cache \
    python3 \
    py3-pip \
    make \
    g++ \
    bash \
    curl \
    git \
    supervisor

# Criar usuário não-root
RUN addgroup -g 1000 appuser && \
    adduser -D -s /bin/bash -u 1000 -G appuser appuser

# Criar diretórios
RUN mkdir -p /app/n8n /app/evolution /var/log/supervisor /home/appuser/.n8n
RUN chown -R appuser:appuser /app /home/appuser

# Instalar n8n globalmente
RUN npm install -g n8n@latest n8n-nodes-evolution-api

# Baixar e configurar Evolution API
WORKDIR /app/evolution
RUN git clone https://github.com/EvolutionAPI/evolution-api.git . && \
    npm install && \
    npm run build

# Configurar supervisor para gerenciar ambos os serviços
COPY <<EOF /etc/supervisor/conf.d/supervisord.conf
[supervisord]
nodaemon=true
user=root

[program:n8n]
command=n8n start
directory=/home/appuser
user=appuser
autostart=true
autorestart=true
stdout_logfile=/var/log/supervisor/n8n.log
stderr_logfile=/var/log/supervisor/n8n.log
environment=HOME="/home/appuser",USER="appuser"

[program:evolution-api]
command=npm run start:prod
directory=/app/evolution
user=appuser
autostart=true
autorestart=true
stdout_logfile=/var/log/supervisor/evolution.log
stderr_logfile=/var/log/supervisor/evolution.log
EOF

# Configurações de ambiente para n8n
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_COMMUNITY_PACKAGES=n8n-nodes-evolution-api
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true
ENV NODE_ENV=production
# Forçar uso de banco externo - sem armazenamento local
ENV DB_TYPE=postgresdb
ENV N8N_SKIP_WEBHOOK_DEREGISTRATION_SHUTDOWN=true
ENV N8N_BLOCK_ENV_ACCESS_IN_NODE=false

# Configurações de ambiente para Evolution API
ENV SERVER_TYPE=http
ENV SERVER_PORT=8080
ENV CORS_ORIGIN=*
ENV QRCODE_GENERATE=true
ENV WEBSOCKET_ENABLED=true
# Forçar uso de banco externo - sem armazenamento local
ENV DATABASE_ENABLED=true
ENV DATABASE_PROVIDER=postgresql
ENV CACHE_REDIS_ENABLED=true
ENV CACHE_REDIS_SAVE_INSTANCES=true
ENV CONFIG_SESSION_PHONE_VERSION=2.3000.1023204200

# Expor portas
EXPOSE 5678 8080

# Criar script de inicialização
RUN echo '#!/bin/bash\n\
    \n\
    # Verificar se as variáveis necessárias estão definidas\n\
    if [ -z "$N8N_BASIC_AUTH_PASSWORD" ]; then\n\
    echo "❌ N8N_BASIC_AUTH_PASSWORD não está definido!"\n\
    exit 1\n\
    fi\n\
    \n\
    if [ -z "$AUTHENTICATION_API_KEY" ]; then\n\
    echo "❌ AUTHENTICATION_API_KEY não está definido!"\n\
    exit 1\n\
    fi\n\
    \n\
    if [ -z "$DATABASE_URL" ]; then\n\
    echo "❌ DATABASE_URL não está definido!"\n\
    exit 1\n\
    fi\n\
    \n\
    # Configurar n8n para banco externo\n\
    export DB_TYPE=postgresdb\n\
    export DATABASE_URL=${DATABASE_URL}\n\
    \n\
    # Configurar Evolution API dinamicamente\n\
    export AUTHENTICATION_API_KEY=${AUTHENTICATION_API_KEY}\n\
    export DATABASE_CONNECTION_URI=${DATABASE_URL}\n\
    export CACHE_REDIS_URI=${REDIS_URL}\n\
    \n\
    # URL interna para comunicação entre serviços\n\
    export EVOLUTION_API_URL="http://localhost:8080"\n\
    \n\
    echo "🚀 Iniciando n8n e Evolution API..."\n\
    echo "📊 N8N será acessível na porta 5678"\n\
    echo "🔗 Evolution API será acessível na porta 8080"\n\
    echo "🗄️  Usando PostgreSQL externo para persistência"\n\
    echo "💾 Dados serão mantidos entre reinicializações"\n\
    \n\
    # Iniciar supervisor\n\
    exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf' > /app/start.sh

RUN chmod +x /app/start.sh
RUN chown appuser:appuser /app/start.sh

# Trocar para usuário não-root
USER appuser
WORKDIR /home/appuser

# Comando de inicialização
CMD ["/app/start.sh"]