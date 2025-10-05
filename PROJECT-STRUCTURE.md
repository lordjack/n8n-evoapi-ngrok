# 📁 Estrutura do Projeto - Organizada

## 📋 **Arquivos Principais**

### **🐳 Docker & Containers**
```
├── Dockerfile                    # Container definitivo (n8n + Evolution API)
├── docker-compose.yml           # Desenvolvimento local com ngrok
├── docker-compose.prod.yml      # Produção auto-hospedada
└── .dockerignore                # Arquivos ignorados no build
```

### **⚙️ Configuração**
```
├── .env                         # Desenvolvimento local
├── .env.example                 # Template de configuração
├── .env.prod                    # Produção auto-hospedada
├── .env.render                  # Render.com (referência)
├── ngrok.yml                    # Configuração do ngrok
└── package.json                 # Scripts do projeto
```

### **📖 Documentação**
```
├── README.md                    # Visão geral e quick start
├── DEPLOY.md                    # Deploy completo + troubleshooting
└── LICENSE                      # Licença MIT
```

### **🔧 Scripts**
```
└── scripts/
    ├── deploy-production.sh     # Deploy produção auto-hospedada (Linux/Mac)
    ├── deploy-production.bat    # Deploy produção auto-hospedada (Windows)
    ├── deploy-render.sh         # Deploy Render.com (Linux/Mac)
    ├── deploy-render.bat        # Deploy Render.com (Windows)
    └── backup-restore.sh        # Backup/restore dados (Render.com)
```

---

## 🗑️ **Arquivos Removidos**

### **Dockerfiles Duplicados:**
- ❌ `Dockerfile.simple`
- ❌ `Dockerfile.npm`
- ❌ `Dockerfile.explicit`
- ❌ `Dockerfile.evolution`
- ❌ `Dockerfile.entrypoint`

### **Configurações Redundantes:**
- ❌ `.env.dev` (consolidado em `.env`)
- ❌ `docker-compose.dev.yml` (consolidado em `docker-compose.yml`)
- ❌ `render.yaml`
- ❌ `test-dockerfile.bat`

### **Documentação Redundante:**
- ❌ `RENDER-SETUP-INSTRUCTIONS.md`
- ❌ `EVOLUTION-API-SETUP.md`
- ❌ `TROUBLESHOOTING.md`

*(Conteúdo consolidado em `DEPLOY.md`)*

---

## 🎯 **Como Usar**

### **Desenvolvimento Local:**
```bash
# Usar configuração padrão
docker-compose up -d

# Com npm
npm run dev
```

### **Produção Auto-hospedada:**
```bash
# Linux/Mac
./scripts/deploy-production.sh

# Windows
scripts\deploy-production.bat

# Manual
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d
```

### **Deploy no Render.com:**
1. Conectar repositório GitHub
2. Configurar variáveis conforme `.env.render`
3. Deploy automático com `Dockerfile`

---

## 📊 **Resumo da Organização**

| Antes | Depois | Redução |
|-------|--------|---------|
| **6 Dockerfiles** | **1 Dockerfile** | ✅ 83% |
| **5 arquivos .env** | **4 arquivos .env** | ✅ 20% |
| **3 docker-compose** | **2 docker-compose** | ✅ 33% |
| **5 arquivos MD** | **2 arquivos MD** | ✅ 60% |
| **3 arquivos extras** | **0 arquivos extras** | ✅ 100% |

**Total**: De **22 arquivos** para **9 arquivos** = **59% de redução** 🎉

---

## 🚀 **Próximos Passos**

1. **Testar** configurações locais
2. **Validar** deploy no Render.com
3. **Documentar** qualquer configuração adicional
4. **Manter** estrutura organizada