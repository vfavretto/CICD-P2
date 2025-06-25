const winston = require('winston');
const { Logtail } = require('@logtail/node');
require('dotenv').config();

// Configuração do Logtail (BetterStack)
const logtail = new Logtail(process.env.LOGTAIL_SOURCE_TOKEN);

// Configuração do Winston
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { service: 'cicd-api' },
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    })
  ]
});

const logToBetterStack = (level, message, meta = {}) => {
  const logData = {
    level,
    message,
    timestamp: new Date().toISOString(),
    ...meta
  };

  try {
    logtail.log(level, message, logData);
  } catch (error) {
    logger.error('Erro ao enviar log para BetterStack:', error);
  }
};

const enhancedLogger = {
  info: (message, meta = {}) => {
    logger.info(message, meta);
    logToBetterStack('info', message, meta);
  },
  error: (message, meta = {}) => {
    logger.error(message, meta);
    logToBetterStack('error', message, meta);
  },
  warn: (message, meta = {}) => {
    logger.warn(message, meta);
    logToBetterStack('warn', message, meta);
  },
  debug: (message, meta = {}) => {
    logger.debug(message, meta);
    logToBetterStack('debug', message, meta);
  }
};

module.exports = enhancedLogger; 