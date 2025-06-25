#!/bin/bash

# Script simplificado para testar a esteira CI/CD
# Executa commits individuais de forma mais prática

set -e

# Cores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Script de Deploy e Teste da Esteira CI/CD${NC}"
echo

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo -e "${RED}Execute este script a partir do diretório raiz do projeto!${NC}"
    exit 1
fi

# Função para executar commits
execute_commit() {
    local commit_msg="$1"
    local files="$2"
    
    echo -e "${BLUE}📝 Fazendo commit: ${commit_msg}${NC}"
    
    if [ -n "$files" ]; then
        git add $files
    else
        git add .
    fi
    
    git commit -m "$commit_msg"
    echo -e "${GREEN}✅ Commit realizado com sucesso!${NC}"
    echo
}

# Menu de opções
echo "Escolha uma opção:"
echo "1. Commit de setup inicial completo"
echo "2. Fazer todos os commits de uma vez (modo automático)"
echo "3. Fazer commits individuais (modo interativo)"
echo "4. Fazer push para GitHub (testar esteira)"
echo "5. Verificar status da esteira"
echo "6. Sair"
echo

read -p "Digite sua escolha (1-6): " choice

case $choice in
    1)
        echo -e "${YELLOW}Fazendo commit inicial completo...${NC}"
        execute_commit "feat: setup inicial completo do projeto CI/CD

- Implementa API REST com CRUD de usuários
- Adiciona documentação Swagger completa  
- Configura logging com Winston e BetterStack
- Implementa middleware de request logging
- Adiciona validação de dados com Sequelize
- Configura Docker e docker-compose para desenvolvimento
- Implementa pipeline CI/CD com GitHub Actions
- Adiciona padronização de commits e Gitflow
- Inclui scripts de setup e deployment
- Documenta todo o processo no README

Ready for production! 🚀"
        
        echo -e "${GREEN}✨ Commit inicial completo realizado!${NC}"
        echo -e "${YELLOW}Execute: git push origin main para testar a esteira${NC}"
        ;;
        
    2)
        echo -e "${YELLOW}Executando todos os commits automaticamente...${NC}"
        
        # Commit 1: Setup base
        execute_commit "feat: setup inicial da API REST

- Implementa estrutura base da API
- Adiciona configuração de banco de dados
- Configura logging básico"

        # Commit 2: Melhorias
        execute_commit "feat: adiciona validação e middlewares

- Implementa validação de entrada
- Adiciona middleware de logging de requisições  
- Melhora tratamento de erros"

        # Commit 3: Docker
        execute_commit "feat: adiciona containerização

- Implementa Dockerfile otimizado
- Adiciona docker-compose para desenvolvimento
- Configura scripts de inicialização"

        # Commit 4: CI/CD
        execute_commit "ci: implementa pipeline CI/CD completo

- Adiciona GitHub Actions
- Configura deploy automático
- Implementa versionamento semântico
- Adiciona notificações de erro"

        # Commit 5: Documentação
        execute_commit "docs: finaliza documentação

- Completa README com instruções
- Adiciona guia de setup detalhado
- Documenta processo de CI/CD
- Inclui scripts de automação"

        echo -e "${GREEN}✨ Todos os commits realizados!${NC}"
        echo -e "${YELLOW}Execute: git push origin main para testar a esteira${NC}"
        ;;
        
    3)
        echo -e "${YELLOW}Modo interativo - pressione ENTER para cada commit${NC}"
        
        echo -e "${BLUE}Commit 1/5: Setup base${NC}"
        read -p "Pressione ENTER para continuar..."
        execute_commit "feat: setup inicial da API REST" ""
        
        echo -e "${BLUE}Commit 2/5: Melhorias${NC}"
        read -p "Pressione ENTER para continuar..."
        execute_commit "feat: adiciona validação e middlewares" ""
        
        echo -e "${BLUE}Commit 3/5: Docker${NC}"
        read -p "Pressione ENTER para continuar..."
        execute_commit "feat: adiciona containerização" ""
        
        echo -e "${BLUE}Commit 4/5: CI/CD${NC}"
        read -p "Pressione ENTER para continuar..."
        execute_commit "ci: implementa pipeline CI/CD completo" ""
        
        echo -e "${BLUE}Commit 5/5: Documentação${NC}"
        read -p "Pressione ENTER para continuar..."
        execute_commit "docs: finaliza documentação" ""
        
        echo -e "${GREEN}✨ Todos os commits interativos realizados!${NC}"
        ;;
        
    4)
        echo -e "${YELLOW}Fazendo push para GitHub...${NC}"
        
        # Verificar se há commits para enviar
        if git diff-index --quiet HEAD --; then
            echo -e "${YELLOW}Nenhuma mudança para commit. Fazendo push dos commits existentes...${NC}"
        else
            echo -e "${YELLOW}Há mudanças não commitadas. Fazendo commit primeiro...${NC}"
            execute_commit "chore: preparação para deploy" ""
        fi
        
        echo -e "${BLUE}🚀 Enviando para GitHub...${NC}"
        git push origin main
        
        echo -e "${GREEN}✅ Push realizado!${NC}"
        echo -e "${YELLOW}🔍 Verifique a esteira em: https://github.com/$(git config --get remote.origin.url | sed 's/.*[:/]\([^/]*\/[^/]*\)\.git/\1/')/actions${NC}"
        ;;
        
    5)
        echo -e "${BLUE}📊 Verificando status...${NC}"
        
        # Status do Git
        echo -e "${YELLOW}Status do Git:${NC}"
        git status --short
        echo
        
        # Últimos commits
        echo -e "${YELLOW}Últimos 5 commits:${NC}"
        git log --oneline -5
        echo
        
        # Verificar se há remote configurado
        if git remote -v | grep -q origin; then
            echo -e "${GREEN}✅ Remote origin configurado${NC}"
            git remote -v
        else
            echo -e "${RED}❌ Remote origin não configurado${NC}"
        fi
        ;;
        
    6)
        echo -e "${BLUE}👋 Até logo!${NC}"
        exit 0
        ;;
        
    *)
        echo -e "${RED}Opção inválida! Execute o script novamente.${NC}"
        exit 1
        ;;
esac

echo
echo -e "${BLUE}📋 Próximos passos recomendados:${NC}"
echo "1. Configure os secrets no GitHub (veja docs/SETUP.md)"
echo "2. Faça push: git push origin main"
echo "3. Monitore a esteira: https://github.com/SEU_USUARIO/CICD-P2/actions"
echo "4. Verifique o deploy no Render"
echo "5. Teste a API em produção"
echo
echo -e "${GREEN}🎉 Pronto para testar a esteira CI/CD!${NC}"