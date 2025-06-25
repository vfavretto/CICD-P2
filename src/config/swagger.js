const swaggerJsdoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'CI/CD API',
      version: '1.0.0',
      description: 'API REST para projeto de CI/CD da FATEC',
      contact: {
        name: 'Victor Favretto',
        email: 'victor@email.com'
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
        url: 'https://api.exemplo.com',
        description: 'Servidor de produção'
      }
    ],
    components: {
      responses: {
        UnauthorizedError: {
          description: 'Token de acesso requerido ou inválido'
        },
        NotFound: {
          description: 'Recurso não encontrado'
        },
        ValidationError: {
          description: 'Erro de validação dos dados'
        },
        ServerError: {
          description: 'Erro interno do servidor'
        }
      }
    }
  },
  apis: ['./src/routes/*.js', './src/app.js'],
};

const specs = swaggerJsdoc(options);

module.exports = {
  specs,
  swaggerUi
}; 