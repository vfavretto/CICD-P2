#!/bin/bash

# Script de configuração automática para o projeto CICD-P2
# Execute com: chmod +x scripts/setup.sh && ./scripts/setup.sh

set -e

echo "🚀 Configurando projeto CICD-P2..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

if [ ! -f "package.json" ]; then
    print_error "Execute este script a partir do diretório raiz do projeto!"
    exit 1
fi

print_status "Verificando pré-requisitos..."

if ! command -v node &> /dev/null; then
    print_error "Node.js não encontrado! Instale o Node.js 18+ antes de continuar."
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    print_error "Node.js versão 18+ é necessária. Versão atual: $(node -v)"
    exit 1
fi
print_success "Node.js $(node -v) encontrado"

if ! command -v npm &> /dev/null; then
    print_error "npm não encontrado!"
    exit 1
fi
print_success "npm $(npm -v) encontrado"

if ! command -v docker &> /dev/null; then
    print_warning "Docker não encontrado. Instale o Docker para usar containers."
else
    print_success "Docker $(docker --version | cut -d' ' -f3) encontrado"
fi

if ! command -v docker-compose &> /dev/null; then
    print_warning "Docker Compose não encontrado. Instale para desenvolvimento local completo."
else
    print_success "Docker Compose encontrado"
fi

if ! command -v git &> /dev/null; then
    print_error "Git não encontrado!"
    exit 1
fi
print_success "Git $(git --version | cut -d' ' -f3) encontrado"

print_status "Configurando ambiente..."

if [ ! -d "logs" ]; then
    mkdir -p logs
    print_success "Diretório de logs criado"
fi

if [ ! -f ".env" ]; then
    if [ -f "env.example" ]; then
        cp env.example .env
        print_success "Arquivo .env criado a partir do env.example"
        print_warning "IMPORTANTE: Configure as variáveis no arquivo .env antes de continuar!"
    else
        print_error "Arquivo env.example não encontrado!"
        exit 1
    fi
else
    print_success "Arquivo .env já existe"
fi

print_status "Instalando dependências do Node.js..."
npm install
print_success "Dependências instaladas com sucesso"

if command -v git-flow &> /dev/null; then
    print_status "Configurando Git Flow..."
    if [ ! -f ".git/config" ] || ! grep -q "gitflow" .git/config; then
        git flow init -d
        print_success "Git Flow configurado"
    else
        print_success "Git Flow já configurado"
    fi
else
    print_warning "Git Flow não encontrado. Instale com: sudo apt-get install git-flow (Ubuntu) ou brew install git-flow-avh (macOS)"
fi

if [ -f ".gitmessage" ]; then
    git config commit.template .gitmessage
    print_success "Template de commit configurado"
else
    print_warning "Arquivo .gitmessage não encontrado"
fi

if command -v docker &> /dev/null; then
    if docker info > /dev/null 2>&1; then
        print_success "Docker está rodando"
        
        read -p "Deseja iniciar o ambiente local com Docker? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Iniciando ambiente Docker..."
            docker-compose up -d
            print_success "Ambiente Docker iniciado!"
            echo
            print_status "Serviços disponíveis:"
            echo "  API: http://localhost:3000"
            echo "  Swagger: http://localhost:3000/api-docs"
            echo "  Health: http://localhost:3000/health"
            echo "   phpMyAdmin: http://localhost:8080"
            echo
            print_status "Aguardando serviços ficarem prontos..."
            sleep 10
            
            if curl -s http://localhost:3000/health > /dev/null; then
                print_success "API está respondendo!"
            else
                print_warning "API pode ainda estar inicializando. Verifique com: docker-compose logs -f"
            fi
        fi
    else
        print_warning "Docker não está rodando. Inicie o Docker antes de usar containers."
    fi
fi

echo
print_success "✨ Configuração concluída!"
echo
print_status "Próximos passos:"
echo "  1. Configure as variáveis no arquivo .env"
echo "  2. Configure os secrets no GitHub (veja docs/SETUP.md)"
echo "  3. Execute 'npm run dev' para desenvolvimento local"
echo "  4. Ou use 'docker-compose up -d' para ambiente containerizado"
echo
print_status "Documentação útil:"
echo "  📖 README.md - Documentação geral"
echo "  ⚙️  docs/SETUP.md - Guia de configuração detalhado"
echo "  🌐 http://localhost:3000/api-docs - Documentação da API (se rodando)"
echo

if [ -f ".env" ]; then
    if grep -q "your_.*_here" .env || grep -q "password" .env; then
        echo
        print_warning "⚠️  LEMBRE-SE de configurar todas as variáveis no arquivo .env antes de fazer deploy!"
        print_warning "Especialmente: LOGTAIL_SOURCE_TOKEN, DB_PASSWORD, etc."
    fi
fi

echo
print_status "🎉 Setup concluído! Bom desenvolvimento!" 