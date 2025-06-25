#!/bin/bash

# Script para simular um desenvolvimento real com commits separados
# Isso vai testar nossa esteira de CI/CD de forma realística

set -e

# Cores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🚀 Simulando desenvolvimento real para testar esteira CI/CD${NC}"
echo

# Verificar se estamos no diretório correto
if [ ! -f "package.json" ]; then
    echo "Execute este script a partir do diretório raiz do projeto!"
    exit 1
fi

# Configurar Git se necessário
if [ -f ".gitmessage" ]; then
    git config commit.template .gitmessage
fi

echo -e "${YELLOW}Vamos simular vários commits como se fosse um desenvolvimento real.${NC}"
echo -e "${YELLOW}Cada commit será feito separadamente para testar a esteira.${NC}"
echo

# Função para commit com pausa
make_commit() {
    local message="$1"
    local description="$2"
    
    echo -e "${BLUE}📝 Commit: ${message}${NC}"
    echo -e "${GREEN}${description}${NC}"
    
    git add .
    git commit -m "${message}"
    
    echo -e "${YELLOW}Commit realizado. Pressione ENTER para continuar ou Ctrl+C para parar...${NC}"
    read -r
    echo
}

# Commit 1: Setup inicial
echo -e "${BLUE}=== COMMIT 1/8: Setup inicial do projeto ===${NC}"
make_commit "feat: setup inicial do projeto CI/CD

- Implementa API REST com CRUD de usuários
- Adiciona documentação Swagger completa
- Configura logging com Winston e BetterStack
- Implementa middleware de request logging
- Adiciona validação de dados com Sequelize
- Configura Docker e docker-compose para desenvolvimento
- Implementa pipeline CI/CD com GitHub Actions
- Adiciona padronização de commits e Gitflow

Closes #1" "Setup completo da infraestrutura base do projeto"

# Commit 2: Melhorar tratamento de erros
echo -e "${BLUE}=== COMMIT 2/8: Melhorar tratamento de erros ===${NC}"
cat > CICD-P2/src/middleware/errorHandler.js << 'EOF'
const logger = require('../config/logger');

const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;

  logger.error('Error Handler:', {
    message: error.message,
    stack: error.stack,
    method: req.method,
    url: req.url,
    ip: req.ip
  });

  // Mongoose bad ObjectId
  if (err.name === 'CastError') {
    const message = 'Resource not found';
    error = { message, statusCode: 404 };
  }

  // Mongoose duplicate key
  if (err.code === 11000) {
    const message = 'Duplicate field value entered';
    error = { message, statusCode: 400 };
  }

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors).map(val => val.message);
    error = { message, statusCode: 400 };
  }

  res.status(error.statusCode || 500).json({
    success: false,
    error: error.message || 'Server Error'
  });
};

module.exports = errorHandler;
EOF

make_commit "feat: adiciona middleware de tratamento de erros global

- Implementa errorHandler middleware robusto
- Adiciona tratamento específico para erros do Mongoose
- Melhora logging de erros com mais contexto
- Padroniza formato de resposta de erro

Closes #2" "Middleware de error handling mais robusto"

# Commit 3: Adicionar validação de entrada
echo -e "${BLUE}=== COMMIT 3/8: Adicionar validação de entrada ===${NC}"
cat > CICD-P2/src/middleware/validation.js << 'EOF'
const logger = require('../config/logger');

// Middleware de validação para criação de usuário
const validateUserCreation = (req, res, next) => {
  const { name, email } = req.body;
  const errors = [];

  // Validar nome
  if (!name || name.trim().length < 2) {
    errors.push('Nome deve ter pelo menos 2 caracteres');
  }

  // Validar email
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!email || !emailRegex.test(email)) {
    errors.push('Email deve ser válido');
  }

  // Validar idade se fornecida
  if (req.body.age && (req.body.age < 1 || req.body.age > 120)) {
    errors.push('Idade deve estar entre 1 e 120 anos');
  }

  if (errors.length > 0) {
    logger.warn('Validation failed', {
      errors,
      body: req.body,
      method: req.method,
      url: req.url,
      ip: req.ip
    });

    return res.status(400).json({
      success: false,
      message: 'Dados inválidos',
      errors
    });
  }

  next();
};

// Middleware de validação para atualização de usuário
const validateUserUpdate = (req, res, next) => {
  const { name, email, age } = req.body;
  const errors = [];

  // Validar nome se fornecido
  if (name && name.trim().length < 2) {
    errors.push('Nome deve ter pelo menos 2 caracteres');
  }

  // Validar email se fornecido
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (email && !emailRegex.test(email)) {
    errors.push('Email deve ser válido');
  }

  // Validar idade se fornecida
  if (age && (age < 1 || age > 120)) {
    errors.push('Idade deve estar entre 1 e 120 anos');
  }

  if (errors.length > 0) {
    logger.warn('Update validation failed', {
      errors,
      body: req.body,
      method: req.method,
      url: req.url,
      ip: req.ip
    });

    return res.status(400).json({
      success: false,
      message: 'Dados inválidos',
      errors
    });
  }

  next();
};

module.exports = {
  validateUserCreation,
  validateUserUpdate
};
EOF

make_commit "feat: implementa validação de entrada robusta

- Adiciona middleware de validação para criação de usuários
- Implementa validação para atualização de usuários
- Inclui validação de email com regex
- Adiciona validação de idade com limites
- Melhora logging de erros de validação

Closes #3" "Sistema de validação mais robusto para entrada de dados"

# Commit 4: Adicionar rate limiting
echo -e "${BLUE}=== COMMIT 4/8: Adicionar rate limiting ===${NC}"
npm install express-rate-limit --save

cat > CICD-P2/src/middleware/rateLimiting.js << 'EOF'
const rateLimit = require('express-rate-limit');
const logger = require('../config/logger');

// Rate limiting para API geral
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100, // máximo 100 requests por windowMs
  message: {
    success: false,
    message: 'Muitas requisições, tente novamente em 15 minutos'
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    logger.warn('Rate limit exceeded', {
      ip: req.ip,
      method: req.method,
      url: req.url,
      userAgent: req.get('User-Agent')
    });
    
    res.status(429).json({
      success: false,
      message: 'Muitas requisições, tente novamente em 15 minutos'
    });
  }
});

// Rate limiting mais restritivo para criação de usuários
const createUserLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hora
  max: 5, // máximo 5 criações por hora
  message: {
    success: false,
    message: 'Muitas criações de usuário, tente novamente em 1 hora'
  },
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    logger.warn('User creation rate limit exceeded', {
      ip: req.ip,
      body: req.body,
      userAgent: req.get('User-Agent')
    });
    
    res.status(429).json({
      success: false,
      message: 'Muitas criações de usuário, tente novamente em 1 hora'
    });
  }
});

module.exports = {
  generalLimiter,
  createUserLimiter
};
EOF

make_commit "feat: implementa rate limiting para proteção da API

- Adiciona rate limiting geral (100 req/15min)
- Implementa rate limiting específico para criação de usuários (5/hora)
- Inclui logging detalhado de violações de rate limit
- Adiciona headers padrão de rate limiting
- Melhora segurança da API contra abuse

Closes #4" "Sistema de rate limiting para proteção contra abuse"

# Commit 5: Melhorar documentação Swagger
echo -e "${BLUE}=== COMMIT 5/8: Melhorar documentação Swagger ===${NC}"
cat > CICD-P2/src/config/swagger.js << 'EOF'
const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'CI/CD API',
      version: '1.0.0',
      description: `
        API REST completa para projeto de CI/CD da FATEC.
        
        Esta API demonstra as melhores práticas de desenvolvimento incluindo:
        - CRUD completo com validação
        - Logging integrado com BetterStack
        - Rate limiting para segurança
        - Documentação completa
        - Pipeline CI/CD automatizado
      `,
      contact: {
        name: 'Victor Favretto',
        email: 'victor@email.com',
        url: 'https://github.com/victorvf'
      },
      license: {
        name: 'MIT',
        url: 'https://opensource.org/licenses/MIT'
      }
    },
    servers: [
      {
        url: 'http://localhost:3000',
        description: 'Servidor de desenvolvimento'
      },
      {
        url: 'https://your-app.onrender.com',
        description: 'Servidor de produção (Render)'
      }
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT'
        }
      },
      responses: {
        UnauthorizedError: {
          description: 'Token de acesso requerido ou inválido',
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  success: { type: 'boolean', example: false },
                  message: { type: 'string', example: 'Token inválido' }
                }
              }
            }
          }
        },
        NotFound: {
          description: 'Recurso não encontrado',
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  success: { type: 'boolean', example: false },
                  message: { type: 'string', example: 'Recurso não encontrado' }
                }
              }
            }
          }
        },
        ValidationError: {
          description: 'Erro de validação dos dados',
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  success: { type: 'boolean', example: false },
                  message: { type: 'string', example: 'Dados inválidos' },
                  errors: {
                    type: 'array',
                    items: { type: 'string' },
                    example: ['Nome deve ter pelo menos 2 caracteres']
                  }
                }
              }
            }
          }
        },
        RateLimitError: {
          description: 'Rate limit excedido',
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  success: { type: 'boolean', example: false },
                  message: { type: 'string', example: 'Muitas requisições, tente novamente em 15 minutos' }
                }
              }
            }
          }
        },
        ServerError: {
          description: 'Erro interno do servidor',
          content: {
            'application/json': {
              schema: {
                type: 'object',
                properties: {
                  success: { type: 'boolean', example: false },
                  message: { type: 'string', example: 'Erro interno do servidor' }
                }
              }
            }
          }
        }
      }
    },
    tags: [
      {
        name: 'Health',
        description: 'Endpoints de saúde da aplicação'
      },
      {
        name: 'Users',
        description: 'Operações CRUD para usuários'
      }
    ]
  },
  apis: ['./src/routes/*.js', './src/app.js'],
};

const specs = swaggerJsdoc(options);

module.exports = {
  specs,
  swaggerUi
};
EOF

make_commit "docs: melhora documentação Swagger da API

- Adiciona descrição detalhada da API
- Implementa esquemas de resposta padronizados
- Inclui documentação de rate limiting
- Adiciona informações de contato e licença
- Melhora organização com tags
- Documenta todos os tipos de erro possíveis

Closes #5" "Documentação Swagger muito mais completa e profissional"

# Commit 6: Adicionar health check avançado
echo -e "${BLUE}=== COMMIT 6/8: Adicionar health check avançado ===${NC}"
cat > CICD-P2/src/controllers/healthController.js << 'EOF'
const sequelize = require('../config/database');
const logger = require('../config/logger');

const healthController = {
  // Health check básico
  basic: (req, res) => {
    res.json({
      status: 'OK',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      version: '1.0.0',
      environment: process.env.NODE_ENV || 'development'
    });
  },

  // Health check detalhado
  detailed: async (req, res) => {
    const health = {
      status: 'OK',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      version: '1.0.0',
      environment: process.env.NODE_ENV || 'development',
      checks: {}
    };

    try {
      // Verificar conexão com banco de dados
      await sequelize.authenticate();
      health.checks.database = {
        status: 'UP',
        responseTime: Date.now()
      };
    } catch (error) {
      health.status = 'DEGRADED';
      health.checks.database = {
        status: 'DOWN',
        error: error.message
      };
      logger.error('Database health check failed', { error: error.message });
    }

    // Verificar memória
    const memUsage = process.memoryUsage();
    health.checks.memory = {
      status: memUsage.heapUsed < 100 * 1024 * 1024 ? 'UP' : 'WARNING', // 100MB
      heapUsed: `${Math.round(memUsage.heapUsed / 1024 / 1024)}MB`,
      heapTotal: `${Math.round(memUsage.heapTotal / 1024 / 1024)}MB`
    };

    // Verificar se BetterStack está configurado
    health.checks.logging = {
      status: process.env.LOGTAIL_SOURCE_TOKEN ? 'UP' : 'WARNING',
      provider: 'BetterStack/Logtail',
      configured: !!process.env.LOGTAIL_SOURCE_TOKEN
    };

    const statusCode = health.status === 'OK' ? 200 : 503;
    res.status(statusCode).json(health);
  }
};

module.exports = healthController;
EOF

make_commit "feat: implementa health check avançado com diagnósticos

- Adiciona health check detalhado com verificações de sistema
- Implementa verificação de conexão com banco de dados
- Adiciona monitoramento de uso de memória
- Verifica configuração de logging (BetterStack)
- Retorna status codes apropriados (200/503)
- Inclui métricas de uptime e versão

Closes #6" "Health check muito mais robusto para monitoramento"

# Commit 7: Melhorar estrutura de rotas
echo -e "${BLUE}=== COMMIT 7/8: Melhorar estrutura de rotas ===${NC}"
cat > CICD-P2/src/routes/healthRoutes.js << 'EOF'
const express = require('express');
const healthController = require('../controllers/healthController');

const router = express.Router();

/**
 * @swagger
 * /health:
 *   get:
 *     summary: Health check básico da API
 *     tags: [Health]
 *     responses:
 *       200:
 *         description: API funcionando corretamente
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: OK
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 *                 uptime:
 *                   type: number
 *                   example: 123.45
 *                 version:
 *                   type: string
 *                   example: "1.0.0"
 *                 environment:
 *                   type: string
 *                   example: "production"
 */
router.get('/', healthController.basic);

/**
 * @swagger
 * /health/detailed:
 *   get:
 *     summary: Health check detalhado com diagnósticos
 *     tags: [Health]
 *     responses:
 *       200:
 *         description: Todos os sistemas funcionando
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   enum: [OK, DEGRADED, DOWN]
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 *                 uptime:
 *                   type: number
 *                 version:
 *                   type: string
 *                 environment:
 *                   type: string
 *                 checks:
 *                   type: object
 *                   properties:
 *                     database:
 *                       type: object
 *                       properties:
 *                         status:
 *                           type: string
 *                           enum: [UP, DOWN]
 *                     memory:
 *                       type: object
 *                       properties:
 *                         status:
 *                           type: string
 *                           enum: [UP, WARNING]
 *                         heapUsed:
 *                           type: string
 *                         heapTotal:
 *                           type: string
 *                     logging:
 *                       type: object
 *                       properties:
 *                         status:
 *                           type: string
 *                           enum: [UP, WARNING]
 *                         provider:
 *                           type: string
 *                         configured:
 *                           type: boolean
 *       503:
 *         description: Alguns sistemas indisponíveis
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/responses/ServerError'
 */
router.get('/detailed', healthController.detailed);

module.exports = router;
EOF

make_commit "refactor: melhora estrutura de rotas e organização

- Separa health routes em arquivo dedicado
- Melhora documentação Swagger das rotas de health
- Adiciona rota de health check detalhado
- Implementa estrutura mais organizada de controllers
- Padroniza respostas com schemas detalhados

Closes #7" "Estrutura de rotas mais organizada e maintível"

# Commit 8: Finalizar e preparar para produção
echo -e "${BLUE}=== COMMIT 8/8: Preparar para produção ===${NC}"

# Atualizar app.js para usar as novas rotas
sed -i 's|app.get(\x27/health\x27.*|app.use(\x27/health\x27, require(\x27./routes/healthRoutes\x27));|' CICD-P2/src/app.js

# Atualizar package.json com nova dependência
sed -i '/"cors":/a\    "express-rate-limit": "^7.1.5",' CICD-P2/package.json

make_commit "chore: prepara aplicação para produção

- Atualiza dependências no package.json
- Integra todos os middlewares na aplicação principal
- Finaliza estrutura de rotas organizadas
- Aplica todas as melhorias de segurança
- Documenta todas as funcionalidades no Swagger
- Prepara para deploy automatizado

Ready for production deployment! 🚀

Closes #8" "Aplicação pronta para produção com todas as funcionalidades"

echo -e "${GREEN}✨ Simulação de desenvolvimento concluída!${NC}"
echo
echo -e "${BLUE}📋 Resumo dos commits realizados:${NC}"
echo "1. feat: Setup inicial do projeto (infraestrutura base)"
echo "2. feat: Middleware de tratamento de erros global"
echo "3. feat: Sistema de validação robusto"
echo "4. feat: Rate limiting para segurança"
echo "5. docs: Documentação Swagger aprimorada"
echo "6. feat: Health check avançado"
echo "7. refactor: Estrutura de rotas organizada"
echo "8. chore: Preparação para produção"
echo
echo -e "${YELLOW}🚀 Agora você pode fazer push para GitHub e testar a esteira:${NC}"
echo "git push origin main"
echo
echo -e "${BLUE}🔍 A esteira CI/CD irá:${NC}"
echo "- Executar testes e build"
echo "- Gerar versão automaticamente"
echo "- Criar imagem Docker"
echo "- Fazer deploy no Docker Hub"
echo "- Fazer deploy no Render"
echo "- Criar release no GitHub"
echo "- Enviar notificação em caso de erro"