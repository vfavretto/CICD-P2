# Guia de Configuração - CICD-P2

Este documento contém instruções detalhadas para configurar o projeto do zero.

## 📋 Checklist de Configuração

### 1. Configuração Inicial
- [ ] Node.js 18+ instalado
- [ ] Docker e Docker Compose instalados
- [ ] Git configurado
- [ ] Conta no GitHub
- [ ] Conta no Docker Hub
- [ ] Conta no Render
- [ ] Conta no BetterStack

### 2. Configuração do BetterStack (Logtail)

1. Acesse https://betterstack.com
2. Crie uma conta gratuita
3. Vá para "Logs" no menu lateral
4. Clique em "Add source"
5. Selecione "HTTP" como tipo de source
6. Copie o **Source Token** gerado
7. Configure no arquivo `.env` como `LOGTAIL_SOURCE_TOKEN`

### 3. Configuração do Docker Hub

1. Acesse https://hub.docker.com
2. Crie uma conta (se não tiver)
3. Anote seu **username**
4. Vá em Account Settings > Security
5. Clique em "New Access Token"
6. Copie o token gerado

### 4. Configuração do Render

1. Acesse https://render.com
2. Crie uma conta
3. Conecte com seu GitHub
4. Crie um novo "Web Service"
5. Conecte ao repositório CICD-P2
6. Configure:
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Node Version**: 18
7. Vá em Settings > Deploy Hook
8. Copie a URL do Deploy Hook

### 5. Configuração de Email para Notificações

Para receber notificações de erro por email:

1. Configure uma conta Gmail com senha de app
2. Vá em Google Account > Security
3. Ative "2-Step Verification"
4. Gere uma "App Password"
5. Use esta senha no secret `EMAIL_PASSWORD`

### 6. Secrets do GitHub

Configure os seguintes secrets em Settings > Secrets and variables > Actions:

```
# Docker Hub
DOCKER_USERNAME=seu_usuario_dockerhub
DOCKER_PASSWORD=seu_token_dockerhub

# Render
RENDER_DEPLOY_HOOK=https://api.render.com/deploy/srv-...

# Banco de Dados (Render Database)
DB_HOST=dpg-...
DB_NAME=cicd_db
DB_USER=seu_usuario
DB_PASSWORD=sua_senha

# BetterStack
LOGTAIL_SOURCE_TOKEN=seu_token_logtail

# Email (Notificações)
EMAIL_USERNAME=seu_email@gmail.com
EMAIL_PASSWORD=sua_senha_app
NOTIFICATION_EMAIL=email_notificacoes@gmail.com
```

### 7. Configuração do Banco de Dados

#### Opção 1: Banco local (Docker)
```bash
docker-compose up -d mysql
```

#### Opção 2: Banco no Render
1. No Render Dashboard, clique em "New +"
2. Selecione "PostgreSQL" ou "MySQL"
3. Configure o nome: `cicd-db`
4. Anote as credenciais geradas
5. Configure nos secrets do GitHub

### 8. Configuração do Gitflow

```bash
# Instalar git-flow (Ubuntu)
sudo apt-get install git-flow

# Instalar git-flow (macOS)
brew install git-flow-avh

# Inicializar gitflow no projeto
cd CICD-P2
git flow init

# Aceitar valores padrão:
# - main branch: main
# - develop branch: develop
# - feature prefix: feature/
# - release prefix: release/
# - hotfix prefix: hotfix/
# - support prefix: support/
# - version tag prefix: v
```

## 🚀 Primeiro Deploy

### 1. Teste Local
```bash
# Clone o projeto
git clone https://github.com/seu-usuario/CICD-P2.git
cd CICD-P2

# Configure variáveis
cp env.example .env
# Edite o .env com suas configurações

# Execute localmente
docker-compose up -d
```

### 2. Push para GitHub
```bash
# Configure template de commit
git config commit.template .gitmessage

# Primeiro commit
git add .
git commit -m "feat: setup inicial do projeto CI/CD

- Implementa API REST com CRUD de usuários
- Adiciona documentação Swagger
- Configura logging com BetterStack
- Adiciona pipeline CI/CD completo
- Configura Docker e docker-compose
- Implementa Gitflow e padronização de commits"

git push origin main
```

### 3. Verificar Pipeline
1. Vá para Actions no GitHub
2. Verifique se o pipeline executou com sucesso
3. Confirme se a imagem foi publicada no Docker Hub
4. Verifique se o deploy foi feito no Render

## 🔧 Troubleshooting

### Erro: "Cannot connect to database"
- Verifique se as credenciais do banco estão corretas
- Confirme se o banco está rodando
- Teste a conexão manualmente

### Erro: "Docker build failed"
- Verifique se o Dockerfile está correto
- Confirme se todas as dependências estão no package.json
- Teste o build localmente

### Erro: "Deploy hook failed"
- Verifique se a URL do deploy hook está correta
- Confirme se todas as variáveis de ambiente estão configuradas
- Verifique logs do Render

### Erro: "BetterStack logs not appearing"
- Confirme se o token do Logtail está correto
- Verifique se há conectividade com a internet
- Teste com logs locais primeiro

## 🆘 Suporte

Se encontrar problemas:

1. Verifique este documento
2. Consulte os logs da aplicação
3. Verifique os logs do pipeline CI/CD