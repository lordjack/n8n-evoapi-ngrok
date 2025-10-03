#!/bin/bash

# Script de Backup/Restore para Render.com (Plano Gratuito)
# Backup de dados críticos do n8n e Evolution API

set -e

# Configurações
BACKUP_DIR="/tmp/backup-$(date +%Y%m%d-%H%M%S)"
DATABASE_URL="${DATABASE_URL}"

if [ -z "$DATABASE_URL" ]; then
    echo "❌ DATABASE_URL não está definido!"
    exit 1
fi

# Função para fazer backup
backup_data() {
    echo "🗂️  Iniciando backup dos dados..."
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup das tabelas do n8n
    echo "📊 Fazendo backup dos workflows n8n..."
    pg_dump "$DATABASE_URL" \
        --table=workflow_entity \
        --table=credentials_entity \
        --table=execution_entity \
        --table=settings \
        --table=webhook_entity \
        --data-only \
        --no-owner \
        --no-privileges > "$BACKUP_DIR/n8n_data.sql"
    
    # Backup das tabelas da Evolution API
    echo "📱 Fazendo backup das instâncias Evolution API..."
    pg_dump "$DATABASE_URL" \
        --table=Instance \
        --table=Message \
        --table=Contact \
        --table=Chat \
        --table=Session \
        --data-only \
        --no-owner \
        --no-privileges > "$BACKUP_DIR/evolution_data.sql"
    
    # Criar arquivo de informações do backup
    cat > "$BACKUP_DIR/backup_info.txt" << EOF
Backup criado em: $(date)
Render Service: ${RENDER_SERVICE_NAME:-unknown}
Database URL: ${DATABASE_URL}
N8N Version: $(n8n --version 2>/dev/null || echo "unknown")

Arquivos incluídos:
- n8n_data.sql: Workflows, credenciais, execuções
- evolution_data.sql: Instâncias WhatsApp, mensagens, contatos
- backup_info.txt: Informações deste backup

Para restaurar:
1. psql "$DATABASE_URL" < n8n_data.sql
2. psql "$DATABASE_URL" < evolution_data.sql
EOF
    
    # Compactar backup
    cd /tmp
    tar -czf "backup-$(date +%Y%m%d-%H%M%S).tar.gz" "$(basename $BACKUP_DIR)"
    
    echo "✅ Backup concluído: backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    echo "📁 Localização: /tmp/"
    echo ""
    echo "⚠️  IMPORTANTE: Baixe este arquivo antes que o container seja reiniciado!"
    echo "💡 Use: curl ou scp para baixar o backup"
}

# Função para restaurar dados
restore_data() {
    local backup_file="$1"
    
    if [ -z "$backup_file" ]; then
        echo "❌ Especifique o arquivo de backup!"
        echo "Uso: $0 restore /caminho/para/backup.tar.gz"
        exit 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        echo "❌ Arquivo de backup não encontrado: $backup_file"
        exit 1
    fi
    
    echo "🔄 Iniciando restauração dos dados..."
    
    # Extrair backup
    local extract_dir="/tmp/restore-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$extract_dir"
    tar -xzf "$backup_file" -C "$extract_dir" --strip-components=1
    
    # Restaurar n8n
    if [ -f "$extract_dir/n8n_data.sql" ]; then
        echo "📊 Restaurando dados do n8n..."
        psql "$DATABASE_URL" < "$extract_dir/n8n_data.sql"
    fi
    
    # Restaurar Evolution API
    if [ -f "$extract_dir/evolution_data.sql" ]; then
        echo "📱 Restaurando dados da Evolution API..."
        psql "$DATABASE_URL" < "$extract_dir/evolution_data.sql"
    fi
    
    echo "✅ Restauração concluída!"
    echo "🔄 Reinicie o serviço para aplicar as mudanças"
}

# Função para verificar o estado dos dados
check_data() {
    echo "🔍 Verificando estado dos dados..."
    
    # Verificar tabelas do n8n
    echo ""
    echo "📊 Tabelas do n8n:"
    psql "$DATABASE_URL" -c "
        SELECT 
            'workflows' as tipo, 
            COUNT(*) as quantidade 
        FROM workflow_entity
        UNION ALL
        SELECT 
            'credentials' as tipo, 
            COUNT(*) as quantidade 
        FROM credentials_entity
        UNION ALL
        SELECT 
            'executions' as tipo, 
            COUNT(*) as quantidade 
        FROM execution_entity;
    " 2>/dev/null || echo "❌ Tabelas do n8n não encontradas"
    
    # Verificar tabelas da Evolution API
    echo ""
    echo "📱 Tabelas da Evolution API:"
    psql "$DATABASE_URL" -c "
        SELECT 
            'instances' as tipo, 
            COUNT(*) as quantidade 
        FROM \"Instance\"
        UNION ALL
        SELECT 
            'messages' as tipo, 
            COUNT(*) as quantidade 
        FROM \"Message\"
        UNION ALL
        SELECT 
            'contacts' as tipo, 
            COUNT(*) as quantidade 
        FROM \"Contact\";
    " 2>/dev/null || echo "❌ Tabelas da Evolution API não encontradas"
}

# Menu principal
case "$1" in
    "backup")
        backup_data
        ;;
    "restore")
        restore_data "$2"
        ;;
    "check")
        check_data
        ;;
    *)
        echo "🔄 Script de Backup/Restore para Render.com"
        echo ""
        echo "Uso:"
        echo "  $0 backup              # Criar backup dos dados"
        echo "  $0 restore arquivo.tar.gz  # Restaurar backup"
        echo "  $0 check               # Verificar estado dos dados"
        echo ""
        echo "Exemplos:"
        echo "  $0 backup"
        echo "  $0 restore /tmp/backup-20231002-143000.tar.gz"
        echo "  $0 check"
        exit 1
        ;;
esac