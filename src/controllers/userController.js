const User = require('../models/User');
const logger = require('../config/logger');

const userController = {
  getAllUsers: async (req, res) => {
    try {
      logger.info('Buscando todos os usuários', { 
        method: req.method, 
        url: req.url,
        ip: req.ip 
      });

      const users = await User.findAll({
        order: [['created_at', 'DESC']]
      });

      logger.info('Usuários encontrados com sucesso', { 
        count: users.length,
        method: req.method,
        url: req.url 
      });

      res.json({
        success: true,
        data: users,
        count: users.length
      });
    } catch (error) {
      logger.error('Erro ao buscar usuários', { 
        error: error.message,
        stack: error.stack,
        method: req.method,
        url: req.url,
        ip: req.ip
      });

      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor',
        error: error.message
      });
    }
  },

  getUserById: async (req, res) => {
    try {
      const { id } = req.params;
      
      logger.info('Buscando usuário por ID', { 
        userId: id,
        method: req.method, 
        url: req.url,
        ip: req.ip 
      });

      const user = await User.findByPk(id);

      if (!user) {
        logger.warn('Usuário não encontrado', { 
          userId: id,
          method: req.method,
          url: req.url 
        });

        return res.status(404).json({
          success: false,
          message: 'Usuário não encontrado'
        });
      }

      logger.info('Usuário encontrado com sucesso', { 
        userId: id,
        method: req.method,
        url: req.url 
      });

      res.json({
        success: true,
        data: user
      });
    } catch (error) {
      logger.error('Erro ao buscar usuário por ID', { 
        error: error.message,
        stack: error.stack,
        userId: req.params.id,
        method: req.method,
        url: req.url,
        ip: req.ip
      });

      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor',
        error: error.message
      });
    }
  },

  createUser: async (req, res) => {
    try {
      const { name, email, age } = req.body;

      logger.info('Criando novo usuário', { 
        userData: { name, email, age },
        method: req.method, 
        url: req.url,
        ip: req.ip 
      });

      const user = await User.create({
        name,
        email,
        age
      });

      logger.info('Usuário criado com sucesso', { 
        userId: user.id,
        method: req.method,
        url: req.url 
      });

      res.status(201).json({
        success: true,
        message: 'Usuário criado com sucesso',
        data: user
      });
    } catch (error) {
      logger.error('Erro ao criar usuário', { 
        error: error.message,
        stack: error.stack,
        userData: req.body,
        method: req.method,
        url: req.url,
        ip: req.ip
      });

      if (error.name === 'SequelizeValidationError') {
        return res.status(400).json({
          success: false,
          message: 'Dados inválidos',
          errors: error.errors.map(err => ({
            field: err.path,
            message: err.message
          }))
        });
      }

      if (error.name === 'SequelizeUniqueConstraintError') {
        return res.status(409).json({
          success: false,
          message: 'Email já está em uso'
        });
      }

      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor',
        error: error.message
      });
    }
  },

  updateUser: async (req, res) => {
    try {
      const { id } = req.params;
      const { name, email, age, active } = req.body;

      logger.info('Atualizando usuário', { 
        userId: id,
        updateData: { name, email, age, active },
        method: req.method, 
        url: req.url,
        ip: req.ip 
      });

      const user = await User.findByPk(id);

      if (!user) {
        logger.warn('Usuário não encontrado para atualização', { 
          userId: id,
          method: req.method,
          url: req.url 
        });

        return res.status(404).json({
          success: false,
          message: 'Usuário não encontrado'
        });
      }

      await user.update({
        name: name || user.name,
        email: email || user.email,
        age: age || user.age,
        active: active !== undefined ? active : user.active
      });

      logger.info('Usuário atualizado com sucesso', { 
        userId: id,
        method: req.method,
        url: req.url 
      });

      res.json({
        success: true,
        message: 'Usuário atualizado com sucesso',
        data: user
      });
    } catch (error) {
      logger.error('Erro ao atualizar usuário', { 
        error: error.message,
        stack: error.stack,
        userId: req.params.id,
        updateData: req.body,
        method: req.method,
        url: req.url,
        ip: req.ip
      });

      if (error.name === 'SequelizeValidationError') {
        return res.status(400).json({
          success: false,
          message: 'Dados inválidos',
          errors: error.errors.map(err => ({
            field: err.path,
            message: err.message
          }))
        });
      }

      if (error.name === 'SequelizeUniqueConstraintError') {
        return res.status(409).json({
          success: false,
          message: 'Email já está em uso'
        });
      }

      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor',
        error: error.message
      });
    }
  },

  deleteUser: async (req, res) => {
    try {
      const { id } = req.params;

      logger.info('Deletando usuário', { 
        userId: id,
        method: req.method, 
        url: req.url,
        ip: req.ip 
      });

      const user = await User.findByPk(id);

      if (!user) {
        logger.warn('Usuário não encontrado para deleção', { 
          userId: id,
          method: req.method,
          url: req.url 
        });

        return res.status(404).json({
          success: false,
          message: 'Usuário não encontrado'
        });
      }

      await user.destroy();

      logger.info('Usuário deletado com sucesso', { 
        userId: id,
        method: req.method,
        url: req.url 
      });

      res.json({
        success: true,
        message: 'Usuário deletado com sucesso'
      });
    } catch (error) {
      logger.error('Erro ao deletar usuário', { 
        error: error.message,
        stack: error.stack,
        userId: req.params.id,
        method: req.method,
        url: req.url,
        ip: req.ip
      });

      res.status(500).json({
        success: false,
        message: 'Erro interno do servidor',
        error: error.message
      });
    }
  }
};

module.exports = userController; 