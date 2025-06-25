const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const sequelize = require('./config/database');
const logger = require('./config/logger');
const requestLogger = require('./middleware/requestLogger');
const { specs, swaggerUi } = require('./config/swagger');
const userRoutes = require('./routes/userRoutes');
const User = require('./models/User');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet());
app.use(cors());

app.use(morgan('combined'));
app.use(requestLogger);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

/**
 * @swagger
 * /health:
 *   get:
 *     summary: Health check da API
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
 *                 timestamp:
 *                   type: string
 *                 uptime:
 *                   type: number
 */
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    version: '1.0.0'
  });
});

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs, {
  customCss: '.swagger-ui .topbar { display: none }',
  customSiteTitle: 'CI/CD API Documentation'
}));

app.use('/api/v1/users', userRoutes);

app.get('/', (req, res) => {
  res.json({
    message: 'Bem-vindo à API CI/CD!',
    documentation: '/api-docs',
    health: '/health',
    version: '1.0.0'
  });
});

app.use('*', (req, res) => {
  logger.warn('Rota não encontrada', {
    method: req.method,
    url: req.originalUrl,
    ip: req.ip
  });

  res.status(404).json({
    success: false,
    message: 'Rota não encontrada',
    path: req.originalUrl
  });
});

app.use((err, req, res, next) => {
  logger.error('Erro não tratado', {
    error: err.message,
    stack: err.stack,
    method: req.method,
    url: req.url,
    ip: req.ip
  });

  res.status(err.status || 500).json({
    success: false,
    message: 'Erro interno do servidor',
    error: process.env.NODE_ENV === 'development' ? err.message : 'Algo deu errado!'
  });
});

async function initializeDatabase() {
  try {
    await sequelize.authenticate();
    logger.info('Conexão com banco de dados estabelecida com sucesso');
    
    await sequelize.sync({ force: false });
    logger.info('Modelos sincronizados com o banco de dados');
    
  } catch (error) {
    logger.error('Erro ao conectar com o banco de dados:', {
      error: error.message,
      stack: error.stack
    });
    process.exit(1);
  }
}

async function startServer() {
  try {
    await initializeDatabase();
    
    app.listen(PORT, () => {
      logger.info(`Servidor rodando na porta ${PORT}`, {
        port: PORT,
        environment: process.env.NODE_ENV || 'development',
        documentation: `http://localhost:${PORT}/api-docs`
      });
    });
  } catch (error) {
    logger.error('Erro ao iniciar servidor:', {
      error: error.message,
      stack: error.stack
    });
    process.exit(1);
  }
}

process.on('SIGTERM', async () => {
  logger.info('Recebido SIGTERM, encerrando aplicação...');
  await sequelize.close();
  process.exit(0);
});

process.on('SIGINT', async () => {
  logger.info('Recebido SIGINT, encerrando aplicação...');
  await sequelize.close();
  process.exit(0);
});

if (require.main === module) {
  startServer();
}

module.exports = app; 