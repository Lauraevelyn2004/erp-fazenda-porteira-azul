CREATE DATABASE IF NOT EXISTS erp_fazenda;
USE erp_fazenda;

-- Usuário do sistema
CREATE TABLE usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    permissao VARCHAR(20) NOT NULL,
    senha_hash VARCHAR(255) NOT NULL
);

-- Funcionários da fazenda
CREATE TABLE funcionario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    funcao VARCHAR(50),
    salario DECIMAL(10,2),
    data_admissao DATE
);

-- Maquinário
CREATE TABLE maquinario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(50),
    modelo VARCHAR(50),
    status VARCHAR(20),
    data_aquisicao DATE,
    funcionario_id INT,
    FOREIGN KEY (funcionario_id) REFERENCES funcionario(id)
);

-- Estoque de produção agrícola
CREATE TABLE estoque_producao (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto ENUM('cafe','soja','milho') NOT NULL,
    quantidade DECIMAL(10,2) NOT NULL,
    local_armazenamento VARCHAR(100)
);

-- Registro de vendas
CREATE TABLE venda (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estoque_id INT NOT NULL,
    quantidade DECIMAL(10,2) NOT NULL,
    preco_venda DECIMAL(10,2) NOT NULL,
    data_venda DATE,
    FOREIGN KEY (estoque_id) REFERENCES estoque_producao(id)
);

-- Módulo de Tomada de Decisão (MTD)
CREATE TABLE mtd (
    id INT AUTO_INCREMENT PRIMARY KEY,
    produto ENUM('cafe','soja','milho') NOT NULL,
    custo_por_saca DECIMAL(10,2) NOT NULL,
    margem DECIMAL(5,2),
    sazonalidade VARCHAR(100),
    recomendacao VARCHAR(100)
);

-- Tabela auxiliar: movimento de estoque por funcionário
CREATE TABLE movimentacao_estoque (
    id INT AUTO_INCREMENT PRIMARY KEY,
    estoque_id INT NOT NULL,
    funcionario_id INT NOT NULL,
    tipo_movimentacao ENUM('entrada','saida','ajuste'),
    quantidade DECIMAL(10,2),
    data_movimentacao DATE,
    FOREIGN KEY (estoque_id) REFERENCES estoque_producao(id),
    FOREIGN KEY (funcionario_id) REFERENCES funcionario(id)
);

-- Usuários do sistema
INSERT INTO usuario (nome, email, permissao, senha_hash) VALUES
    ('Laura Evelyn', 'laura@email.com', 'admin', 'HASHEDPASS1'),
    ('Amanda Silva', 'amanda@email.com', 'usuario', 'HASHEDPASS2');

-- Funcionários
INSERT INTO funcionario (nome, funcao, salario, data_admissao) VALUES
    ('Carlos Ferreira', 'Operador de Maquinário', 3400.00, '2023-02-10'),
    ('Maria Souza', 'Estoquista', 2500.00, '2024-06-01');

-- Maquinário
INSERT INTO maquinario (tipo, modelo, status, data_aquisicao, funcionario_id) VALUES
    ('Colheitadeira', 'John Deere S770', 'disponível', '2022-10-15', 1),
    ('Trator', 'Massey Ferguson 7719', 'manutenção', '2021-08-22', 2);

-- Estoque de produção
INSERT INTO estoque_producao (produto, quantidade, local_armazenamento) VALUES
    ('cafe', 1500.00, 'Armazém Principal'),
    ('soja', 4000.00, 'Silo Norte'),
    ('milho', 2300.00, 'Galpão Oeste');

-- Movimento de estoque
INSERT INTO movimentacao_estoque (estoque_id, funcionario_id, tipo_movimentacao, quantidade, data_movimentacao) VALUES
    (1, 2, 'entrada', 100.00, '2025-10-01'),
    (3, 1, 'saida', 200.00, '2025-10-05');

-- Vendas
INSERT INTO venda (estoque_id, quantidade, preco_venda, data_venda) VALUES
    (1, 50.00, 600.00, '2025-10-10'),
    (2, 350.00, 120.00, '2025-10-15');

-- Módulo de Tomada de Decisão (MTD)
INSERT INTO mtd (produto, custo_por_saca, margem, sazonalidade, recomendacao) VALUES
    ('cafe', 450.00, 0.18, 'Alta safra', 'Esperar melhor preço'),
    ('soja', 80.00, 0.22, 'Em queda', 'Vender rapidamente'),
    ('milho', 60.00, 0.15, 'Estável', 'Manter em estoque');
