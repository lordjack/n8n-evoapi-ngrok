# Dockerfile simples para Render.com - apenas n8n
FROM n8nio/n8n:latest

# Mudar para usuário root temporariamente para instalar pacotes
USER root

# Instalar dependências do sistema necessárias
RUN apk add --no-cache curl postgresql-client

# Voltar para o usuário n8n
USER node

# Configurações de ambiente para produção
ENV NODE_ENV=production
ENV N8N_LOG_LEVEL=info
ENV N8N_METRICS=true
ENV N8N_COMMUNITY_PACKAGES=n8n-nodes-evolution-api

# Expor a porta do n8n
EXPOSE 5678

# Comando de inicialização
CMD ["n8n", "start"]