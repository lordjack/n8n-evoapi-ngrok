# Dockerfile ultra-simples para Render.com
FROM n8nio/n8n:latest

# Configurações de ambiente para produção
ENV NODE_ENV=production
ENV N8N_LOG_LEVEL=info
ENV N8N_METRICS=true
ENV N8N_COMMUNITY_PACKAGES=n8n-nodes-evolution-api
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=false
ENV N8N_BLOCK_ENV_ACCESS_IN_NODE=false
ENV N8N_DEFAULT_TIMEZONE=America/Recife

# Configurações de banco com valores padrão
ENV DB_TYPE=postgresdb
ENV DB_POSTGRESDB_HOST=localhost
ENV DB_POSTGRESDB_PORT=5432
ENV DB_POSTGRESDB_USER=postgres
ENV DB_POSTGRESDB_PASSWORD=password
ENV DB_POSTGRESDB_DATABASE=n8n

# Expor porta
EXPOSE 5678

# Comando direto do n8n - mais simples e confiável
CMD ["tini", "--", "/usr/local/bin/n8n", "start"]