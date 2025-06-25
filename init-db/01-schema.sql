CREATE DATABASE IF NOT EXISTS cicd_db;
USE cicd_db;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    age INT DEFAULT NULL,
    active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO users (name, email, age, active) VALUES
('João Silva', 'joao@exemplo.com', 30, TRUE),
('Maria Santos', 'maria@exemplo.com', 25, TRUE),
('Pedro Oliveira', 'pedro@exemplo.com', 35, FALSE),
('Ana Costa', 'ana@exemplo.com', 28, TRUE)
ON DUPLICATE KEY UPDATE name=VALUES(name);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_active ON users(active);
CREATE INDEX IF NOT EXISTS idx_users_created_at ON users(created_at); 