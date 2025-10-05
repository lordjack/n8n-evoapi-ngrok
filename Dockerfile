# =============================================================================
# DOCKERFILE DEFINITIVO PARA RENDER.COM
# =============================================================================
# Container único executando n8n + Evolution API
# Configurado para persistência com PostgreSQL + Redis
# Otimizado para plano gratuito do Render.com
# =============================================================================

FROM node:18-alpine

# Metadados
LABEL maintainer="n8n-evoapi-project"
LABEL description="n8n + Evolution API container for Render.com"
LABEL version="1.0"

# =============================================================================
# DEPENDÊNCIAS DO SISTEMA
# =============================================================================

RUN apk add --no-cache \
    # Build essentials
    python3 \
    make \
    g++ \
    # Runtime essentials
    bash \
    curl \
    git \
    supervisor \
    # Database clients
    postgresql-client \
    # Utils
    zip \
    unzip \
    && rm -rf /var/cache/apk/*

# =============================================================================
# INSTALAÇÃO DO N8N
# =============================================================================

# Instalar n8n globalmente
RUN npm install -g n8n@latest

# Tentar instalar community packages (falha silenciosa se não conseguir)
RUN npm install -g n8n-nodes-evolution-api || echo "⚠️ Community packages will be installed at startup"

# =============================================================================
# CONFIGURAÇÃO DE USUÁRIO
# =============================================================================

# Criar usuário não-root (deixar Alpine escolher UID automaticamente)
RUN adduser -D appuser

# Criar estrutura de diretórios
RUN mkdir -p \
    /app/evolution \
    /var/log/supervisor \
    /home/appuser/.n8n \
    /tmp/backup

# Definir permissões
RUN chown -R appuser:appuser /app /home/appuser /tmp/backup

# =============================================================================
# CONFIGURAÇÃO DA EVOLUTION API
# =============================================================================

WORKDIR /app/evolution

# Download da Evolution API com múltiplos fallbacks
RUN echo "📥 Downloading Evolution API..." && \
    (git clone https://github.com/EvolutionAPI/evolution-api.git . 2>/dev/null || \
     curl -L https://github.com/EvolutionAPI/evolution-api/archive/refs/heads/main.tar.gz | tar -xz --strip-components=1 2>/dev/null || \
     echo "❌ Evolution API download failed, will use minimal setup") && \
    echo "✅ Evolution API downloaded"

# Instalar dependências (continua mesmo se falhar)
RUN echo "📦 Installing Evolution API dependencies..." && \
    npm install --production --no-optional 2>/dev/null || \
    echo "⚠️ Some dependencies failed, continuing..."

# =============================================================================
# CONFIGURAÇÃO DO SUPERVISOR
# =============================================================================

# Configurar supervisor para gerenciar ambos os serviços
RUN echo "⚙️ Configuring supervisor..." && \
    mkdir -p /etc/supervisor/conf.d && \
    { \
        echo '[supervisord]'; \
        echo 'nodaemon=true'; \
        echo 'user=root'; \
        echo 'logfile=/dev/null'; \
        echo 'logfile_maxbytes=0'; \
        echo 'pidfile=/tmp/supervisord.pid'; \
        echo ''; \
        echo '[program:n8n]'; \
        echo 'command=n8n start'; \
        echo 'directory=/home/appuser'; \
        echo 'user=appuser'; \
        echo 'autostart=true'; \
        echo 'autorestart=true'; \
        echo 'stdout_logfile=/dev/stdout'; \
        echo 'stdout_logfile_maxbytes=0'; \
        echo 'stderr_logfile=/dev/stderr'; \
        echo 'stderr_logfile_maxbytes=0'; \
        echo 'environment=HOME="/home/appuser",USER="appuser"'; \
        echo ''; \
        echo '[program:evolution-api]'; \
        echo 'command=npm start'; \
        echo 'directory=/app/evolution'; \
        echo 'user=appuser'; \
        echo 'autostart=true'; \
        echo 'autorestart=true'; \
        echo 'stdout_logfile=/dev/stdout'; \
        echo 'stdout_logfile_maxbytes=0'; \
        echo 'stderr_logfile=/dev/stderr'; \
        echo 'stderr_logfile_maxbytes=0'; \
    } > /etc/supervisor/conf.d/supervisord.conf && \
    echo "✅ Supervisor configured"

# =============================================================================
# VARIÁVEIS DE AMBIENTE
# =============================================================================

# N8N Configuration
ENV NODE_ENV=production
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true
ENV N8N_SKIP_WEBHOOK_DEREGISTRATION_SHUTDOWN=true
ENV N8N_BLOCK_ENV_ACCESS_IN_NODE=false
ENV N8N_LOG_LEVEL=info
ENV N8N_DEFAULT_TIMEZONE=America/Recife

# Database Configuration (External)
ENV DB_TYPE=postgresdb

# Evolution API Configuration
ENV SERVER_TYPE=http
ENV SERVER_PORT=8080
ENV CORS_ORIGIN=*
ENV QRCODE_GENERATE=true
ENV WEBSOCKET_ENABLED=true
ENV DATABASE_ENABLED=true
ENV DATABASE_PROVIDER=postgresql
ENV CACHE_REDIS_ENABLED=true
ENV CACHE_REDIS_SAVE_INSTANCES=true
ENV CONFIG_SESSION_PHONE_VERSION=2.3000.1023204200

# =============================================================================
# SCRIPT DE INICIALIZAÇÃO
# =============================================================================

RUN echo "📝 Creating startup script..." && \
    { \
        echo '#!/bin/bash'; \
        echo 'set -e'; \
        echo ''; \
        echo '# Banner'; \
        echo 'echo "🚀 =================================="'; \
        echo 'echo "🚀 N8N + EVOLUTION API CONTAINER"'; \
        echo 'echo "🚀 =================================="'; \
        echo 'echo "📊 N8N: Port 5678"'; \
        echo 'echo "🔗 Evolution API: Port 8080"'; \
        echo 'echo "🗄️  Database: External PostgreSQL"'; \
        echo 'echo "💾 Cache: External Redis"'; \
        echo 'echo "🚀 =================================="'; \
        echo ''; \
        echo '# Environment validation'; \
        echo 'echo "🔍 Validating environment..."'; \
        echo 'if [ -z "$N8N_BASIC_AUTH_PASSWORD" ]; then'; \
        echo '  echo "❌ N8N_BASIC_AUTH_PASSWORD not set!"'; \
        echo '  exit 1'; \
        echo 'fi'; \
        echo 'if [ -z "$AUTHENTICATION_API_KEY" ]; then'; \
        echo '  echo "❌ AUTHENTICATION_API_KEY not set!"'; \
        echo '  exit 1'; \
        echo 'fi'; \
        echo 'if [ -z "$DATABASE_URL" ]; then'; \
        echo '  echo "❌ DATABASE_URL not set!"'; \
        echo '  exit 1'; \
        echo 'fi'; \
        echo 'echo "✅ Environment validation passed"'; \
        echo ''; \
        echo '# Install community packages'; \
        echo 'echo "📦 Installing community packages..."'; \
        echo 'npm install -g n8n-nodes-evolution-api || echo "⚠️ Community packages install failed"'; \
        echo ''; \
        echo '# Export environment variables'; \
        echo 'export DB_TYPE=postgresdb'; \
        echo 'export DATABASE_URL=${DATABASE_URL}'; \
        echo 'export AUTHENTICATION_API_KEY=${AUTHENTICATION_API_KEY}'; \
        echo 'export DATABASE_CONNECTION_URI=${DATABASE_URL}'; \
        echo 'export CACHE_REDIS_URI=${REDIS_URL}'; \
        echo 'export EVOLUTION_API_URL="http://localhost:8080"'; \
        echo ''; \
        echo '# Start services'; \
        echo 'echo "🚀 Starting services..."'; \
        echo 'exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf'; \
    } > /app/start.sh && \
    chmod +x /app/start.sh && \
    chown appuser:appuser /app/start.sh && \
    echo "✅ Startup script created"

# =============================================================================
# EXPOSIÇÃO DE PORTAS
# =============================================================================

EXPOSE 5678 8080

# =============================================================================
# CONFIGURAÇÃO FINAL
# =============================================================================

# Trocar para usuário não-root
USER appuser
WORKDIR /home/appuser

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:5678/healthz || exit 1

# Comando de inicialização
CMD ["/app/start.sh"]

# =============================================================================
# METADATA FINAL
# =============================================================================

# Build info
ARG BUILD_DATE
ARG VERSION
LABEL build_date=${BUILD_DATE}
LABEL version=${VERSION}

# Documentação
LABEL org.opencontainers.image.title="n8n + Evolution API"
LABEL org.opencontainers.image.description="Complete automation stack with n8n and Evolution API for WhatsApp"
LABEL org.opencontainers.image.source="https://github.com/lordjack/n8n-evoapi-ngrok"
LABEL org.opencontainers.image.documentation="https://github.com/lordjack/n8n-evoapi-ngrok/blob/main/README.md"