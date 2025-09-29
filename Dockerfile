# Dockerfile para Render.com
FROM n8nio/n8n:latest

# Configurações básicas para produção
ENV NODE_ENV=production
ENV N8N_LOG_LEVEL=info
ENV N8N_METRICS=true
ENV N8N_COMMUNITY_PACKAGES=n8n-nodes-evolution-api
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false
ENV N8N_BLOCK_ENV_ACCESS_IN_NODE=false
ENV N8N_DEFAULT_TIMEZONE=America/Recife

# Configuração simplificada de banco (usar DATABASE_URL do Render)
ENV DB_TYPE=postgresdb

# Expor porta
EXPOSE 5678

# Usar comando com caminho completo e tini
CMD ["tini", "--", "/usr/local/bin/docker-entrypoint.sh", "n8n", "start"]