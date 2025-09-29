# Dockerfile para Render.com - n8n otimizado
FROM n8nio/n8n:latest

# Mudar para usuário root temporariamente
USER root

# Instalar dependências necessárias
RUN apk add --no-cache curl postgresql-client bash

# Voltar para o usuário node
USER node

# Configurações de ambiente para produção
ENV NODE_ENV=production
ENV N8N_LOG_LEVEL=info
ENV N8N_METRICS=true
ENV N8N_COMMUNITY_PACKAGES=n8n-nodes-evolution-api

# Configurações de banco padrão (serão sobrescritas pelas variáveis do Render)
ENV DB_TYPE=postgresdb
ENV DB_POSTGRESDB_HOST=localhost
ENV DB_POSTGRESDB_PORT=5432
ENV DB_POSTGRESDB_USER=postgres
ENV DB_POSTGRESDB_PASSWORD=password
ENV DB_POSTGRESDB_DATABASE=n8n

# Configurações extras
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false
ENV N8N_BLOCK_ENV_ACCESS_IN_NODE=false
ENV N8N_DEFAULT_TIMEZONE=America/Recife

# Expor a porta do n8n
EXPOSE 5678

# Criar script de inicialização
RUN echo '#!/bin/bash' > /usr/local/bin/start-n8n.sh && \
    echo 'echo "🚀 Iniciando n8n..."' >> /usr/local/bin/start-n8n.sh && \
    echo 'echo "Database URL: $DATABASE_URL"' >> /usr/local/bin/start-n8n.sh && \
    echo 'echo "Node ENV: $NODE_ENV"' >> /usr/local/bin/start-n8n.sh && \
    echo 'exec /usr/local/bin/n8n start' >> /usr/local/bin/start-n8n.sh && \
    chmod +x /usr/local/bin/start-n8n.sh

# Comando de inicialização usando o script
CMD ["/usr/local/bin/start-n8n.sh"]