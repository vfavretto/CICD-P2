# CICD-P2 - API REST com Pipeline CI/CD

Este projeto implementa uma API REST completa com pipeline CI/CD automatizado para a disciplina de CI/CD da FATEC.

## 🚀 Funcionalidades

- ✅ **API REST** com operações CRUD
- ✅ **Documentação Swagger** automática
- ✅ **Logging completo** de todas as requisições
- ✅ **Integração com BetterStack** para logs em produção
- ✅ **Banco MySQL** com Sequelize ORM
- ✅ **Pipeline CI/CD** automatizado
- ✅ **Containerização** com Docker
- ✅ **Deploy automatizado** no Render
- ✅ **Gitflow** e padronização de commits

## 📋 Pré-requisitos

- Node.js 18+
- Docker e Docker Compose
- MySQL (para desenvolvimento local)
- Conta no GitHub (para CI/CD)
- Conta no Docker Hub
- Conta no Render
- Conta no BetterStack (Logtail)

## 🛠️ Configuração Local

### 1. Clone o repositório
```bash
git clone https://github.com/seu-usuario/CICD-P2.git
cd CICD-P2
```

### 2. Configure as variáveis de ambiente
```bash
cp env.example .env
```

Edite o arquivo `.env` com suas configurações:
```env
# Database Configuration
DB_HOST=localhost
DB_PORT=3306
DB_NAME=cicd_db
DB_USER=apiuser
DB_PASSWORD=apipassword

# BetterStack Configuration
LOGTAIL_SOURCE_TOKEN=your_logtail_token_here

# Server Configuration
PORT=3000
NODE_ENV=development
```

### 3. Instale as dependências
```bash
npm install
```

### 4. Execute com Docker Compose (Recomendado)
```bash
docker-compose up -d
```

Isso irá iniciar:
- MySQL na porta 3306
- API na porta 3000
- phpMyAdmin na porta 8080

### 5. Ou execute localmente
```bash
# Certifique-se que o MySQL está rodando
npm run dev
```

## 📖 Documentação da API

Após iniciar a aplicação, acesse:

- **Swagger UI**: http://localhost:3000/api-docs
- **Health Check**: http://localhost:3000/health
- **phpMyAdmin**: http://localhost:8080 (usuário: root, senha: rootpassword)

### Endpoints Disponíveis

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | `/api/v1/users` | Lista todos os usuários |
| GET | `/api/v1/users/:id` | Busca usuário por ID |
| POST | `/api/v1/users` | Cria novo usuário |
| PUT | `/api/v1/users/:id` | Atualiza usuário |
| DELETE | `/api/v1/users/:id` | Remove usuário |

### Exemplo de Requisição
```bash
# Criar usuário
curl -X POST http://localhost:3000/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "João Silva",
    "email": "joao@exemplo.com",
    "age": 30
  }'
```

## 🔄 Pipeline CI/CD

O projeto utiliza GitHub Actions para automação completa:

### Etapas do CI (Continuous Integration)
1. **Checkout** - Download do código
2. **Install** - Instalação de dependências
3. **Build** - Build da aplicação
4. **Versionamento** - Geração automática de versão
5. **Build Imagem** - Criação da imagem Docker

### Etapas do CD (Continuous Deployment)
1. **Deploy Docker Hub** - Publicação da imagem
2. **TAG Latest** - Criação da tag latest
3. **Deploy Render** - Deploy na plataforma
4. **Notificação Email** - Em caso de erro

### Secrets Necessários

Configure os seguintes secrets no GitHub:

```
DOCKER_USERNAME=seu_usuario_dockerhub
DOCKER_PASSWORD=sua_senha_dockerhub
RENDER_DEPLOY_HOOK=https://api.render.com/deploy/...
DB_HOST=seu_host_mysql
DB_NAME=cicd_db
DB_USER=seu_usuario_mysql
DB_PASSWORD=sua_senha_mysql
LOGTAIL_SOURCE_TOKEN=seu_token_logtail
EMAIL_USERNAME=seu_email@gmail.com
EMAIL_PASSWORD=sua_senha_app
NOTIFICATION_EMAIL=email_para_notificacoes@gmail.com
```

## 📝 Padronização de Commits

Este projeto segue o padrão **Conventional Commits**:

```bash
# Configure o template de commit
git config commit.template .gitmessage
```

### Tipos de commit:
- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Mudanças na documentação
- `style`: Formatação, espaços em branco
- `refactor`: Refatoração sem mudança de funcionalidade
- `test`: Adição ou correção de testes
- `chore`: Tarefas de build, configurações
- `perf`: Melhoria de performance
- `ci`: Mudanças nos arquivos de CI/CD

### Exemplo:
```
feat: adiciona endpoint para criação de usuário

- Implementa POST /api/v1/users
- Adiciona validação de email único
- Inclui documentação Swagger

Closes #123
```

## 🌿 Gitflow

O projeto utiliza Gitflow para organização das branches:

- `main` - Branch de produção
- `develop` - Branch de desenvolvimento
- `feature/*` - Novas funcionalidades
- `hotfix/*` - Correções urgentes
- `release/*` - Preparação de releases

```bash
# Inicializar Gitflow
git flow init

# Criar nova feature
git flow feature start nova-funcionalidade

# Finalizar feature
git flow feature finish nova-funcionalidade
```

## 📊 Logs e Monitoramento

### Logs Locais
Os logs são salvos em:
- `logs/error.log` - Apenas erros
- `logs/combined.log` - Todos os logs

### BetterStack (Logtail)
1. Crie uma conta em https://betterstack.com
2. Crie um novo stream de logs
3. Copie o token e configure como `LOGTAIL_SOURCE_TOKEN`

Todos os logs da aplicação são enviados automaticamente para o BetterStack.

## 🐳 Docker

### Build manual
```bash
docker build -t cicd-api .
docker run -p 3000:3000 cicd-api
```

### Comandos úteis
```bash
# Ver logs dos containers
docker-compose logs -f

# Parar todos os containers
docker-compose down

# Rebuild da aplicação
docker-compose up --build api
```

## 🚀 Deploy

### Deploy Manual no Render
1. Crie um Web Service no Render
2. Conecte com seu repositório GitHub
3. Configure as variáveis de ambiente
4. O deploy será automático a cada push na main

### Deploy Automático
O pipeline CI/CD fará o deploy automaticamente quando:
- Houver push na branch `main`
- Todos os testes passarem
- A imagem Docker for construída com sucesso

## 🧪 Testes

```bash
# Executar testes (quando implementados)
npm test

# Verificar health da API
curl http://localhost:3000/health
```

## 📁 Estrutura do Projeto

```
CICD-P2/
├── .github/workflows/    # Pipelines CI/CD
├── src/
│   ├── config/          # Configurações (DB, logs, Swagger)
│   ├── controllers/     # Controllers da API
│   ├── middleware/      # Middlewares (logs, auth)
│   ├── models/          # Modelos do banco
│   ├── routes/          # Rotas da API
│   └── app.js          # Arquivo principal
├── init-db/            # Scripts de inicialização do DB
├── logs/               # Logs locais
├── docker-compose.yml  # Configuração Docker local
├── Dockerfile          # Imagem Docker da aplicação
└── README.md          # Este arquivo
```

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma feature branch (`git flow feature start feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'feat: adiciona funcionalidade incrível'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para detalhes.

## 👨‍💻 Autor

**Victor Favretto**
- GitHub: [@victorvf](https://github.com/victorvf)
- Email: victor@email.com

---

> Este projeto foi desenvolvido para a disciplina de CI/CD da FATEC como demonstração prática de DevOps e automação.
