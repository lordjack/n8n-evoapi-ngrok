# 🚨 Troubleshooting - Render.com Deploy

## ❌ Problemas Comuns e Soluções

### 1. **Error: Command "n8n" not found** ou **tini error**

**Causa**: Comando CMD incorreto no Dockerfile ou problemas com tini
**Solução**: Use o entrypoint simplificado

```dockerfile
# ✅ CORRETO (sem tini)
CMD ["/usr/local/bin/docker-entrypoint.sh", "n8n", "start"]

# ❌ INCORRETO - com tini (pode dar erro no Render)
CMD ["tini", "--", "/usr/local/bin/docker-entrypoint.sh", "n8n", "start"]

# ❌ INCORRETO - comando direto
CMD ["n8n", "start"]
```

### 2. **Invalid number value for DB_POSTGRESDB_PORT: ${POSTGRES_PORT}**

**Causa**: Variáveis de ambiente conflitantes
**Solução**: Use APENAS `DATABASE_URL`

```bash
# ✅ CORRETO - Apenas DATABASE_URL
DATABASE_URL=postgresql://user:pass@host:port/db

# ❌ INCORRETO - Variáveis individuais
DB_POSTGRESDB_HOST=host
DB_POSTGRESDB_PORT=5432
```

### 3. **No encryption key found**

**Causa**: Normal na primeira inicialização
**Status**: ✅ Auto-resolvido (n8n gera automaticamente)

### 4. **Exited with status 1**

**Causas possíveis**:
- Variáveis de ambiente incorretas
- Comando CMD inválido
- Falha na conexão com banco

**Soluções**:
1. Verificar variáveis no dashboard
2. Confirmar DATABASE_URL
3. Ver logs detalhados

## 🔧 Configuração Correta no Render

### Variáveis OBRIGATÓRIAS:
```bash
NODE_ENV=production
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=sua_senha_123
DATABASE_URL=postgresql://... (do PostgreSQL criado)
```

### Variáveis OPCIONAIS:
```bash
N8N_LOG_LEVEL=info
N8N_COMMUNITY_PACKAGES=n8n-nodes-evolution-api
N8N_METRICS=true
N8N_DEFAULT_TIMEZONE=America/Recife
```

### ❌ NÃO configure:
- `DB_TYPE=postgresdb`
- `DB_POSTGRESDB_*` (qualquer variável individual)
- Variáveis que referenciam `${POSTGRES_*}`

## 📋 Checklist para Deploy

- [ ] PostgreSQL Database criado no Render
- [ ] DATABASE_URL copiada corretamente
- [ ] Apenas variáveis recomendadas configuradas
- [ ] Dockerfile com CMD correto
- [ ] Código commitado no GitHub
- [ ] Build completado sem erros

## 🔍 Como Ver Logs Detalhados

1. **Dashboard Render** → Seu serviço
2. **Logs** tab
3. **Live tail** para logs em tempo real
4. **Events** para histórico de deploys

## 🆘 Se Ainda Não Funcionar

1. **Deletar** todas as variáveis de ambiente
2. **Configurar** apenas as obrigatórias
3. **Redeploy** manual
4. **Aguardar** 5-10 minutos
5. **Verificar** logs novamente