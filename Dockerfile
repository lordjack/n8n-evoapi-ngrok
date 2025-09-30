# Dockerfile para Render.com com Evolution API
FROM n8nio/n8n:latest

# Mudar para usuário root para instalar pacotes
USER root

# Atualizar npm e instalar o pacote Evolution API
RUN npm install -g npm@latest && \
    npm install -g n8n-nodes-evolution-api && \
    npm cache clean --force

# Voltar para usuário node
USER node

# Configurações para produção
ENV NODE_ENV=production
ENV N8N_BASIC_AUTH_ACTIVE=true
ENV N8N_COMMUNITY_PACKAGES=n8n-nodes-evolution-api
ENV N8N_COMMUNITY_PACKAGES_ENABLED=true

# Expor porta
EXPOSE 5678

# Comando de inicialização que força instalação se necessário
CMD ["sh", "-c", "npm list -g n8n-nodes-evolution-api || npm install -g n8n-nodes-evolution-api; n8n start"]