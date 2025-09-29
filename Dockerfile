# Dockerfile ultra-simples para Render.com
FROM n8nio/n8n:latest

# Configurações mínimas para produção
ENV NODE_ENV=production
ENV N8N_BASIC_AUTH_ACTIVE=true

# Expor porta
EXPOSE 5678

# Comando direto - sem entrypoint customizado
CMD ["n8n", "start"]