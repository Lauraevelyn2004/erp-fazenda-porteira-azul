

-- ============================================================================
-- SCRIPTS SQL PARA O SISTEMA DE BIBLIOTECA - MySQL
-- ============================================================================

-- Criação do banco de dados
CREATE DATABASE IF NOT EXISTS biblioteca_db;
USE biblioteca_db;

-- ============================================================================
-- TABELA: usuario
-- Descrição: Armazena os dados dos usuários da biblioteca
-- ============================================================================
CREATE TABLE usuario (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ativo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- TABELA: livro
-- Descrição: Armazena os dados dos livros da biblioteca
-- ============================================================================
CREATE TABLE livro (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(200) NOT NULL,
    autor VARCHAR(100) NOT NULL,
    isbn VARCHAR(17) UNIQUE NOT NULL,
    editora VARCHAR(100),
    ano_publicacao INT,
    quantidade_total INT NOT NULL DEFAULT 0,
    quantidade_disponivel INT NOT NULL DEFAULT 0,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- TABELA: emprestimo
-- Descrição: Armazena os dados dos empréstimos de livros
-- ============================================================================
CREATE TABLE emprestimo (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    usuario_id BIGINT NOT NULL,
    livro_id BIGINT NOT NULL,
    data_emprestimo DATE NOT NULL,
    data_devolucao_prevista DATE NOT NULL,
    data_devolucao_real DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'ATIVO',
    observacoes TEXT,
    FOREIGN KEY (usuario_id) REFERENCES usuario(id) ON DELETE CASCADE,
    FOREIGN KEY (livro_id) REFERENCES livro(id) ON DELETE CASCADE,
    INDEX idx_usuario (usuario_id),
    INDEX idx_livro (livro_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ============================================================================
-- INSERÇÃO DE DADOS DE TESTE
-- ============================================================================

-- Inserindo usuários de teste
INSERT INTO usuario (nome, cpf, email, senha) VALUES
('Admin Sistema', '000.000.000-00', 'admin@biblioteca.com', 'admin123'),
('João Silva', '111.111.111-11', 'joao@email.com', 'senha123'),
('Maria Santos', '222.222.222-22', 'maria@email.com', 'senha123');

-- Inserindo livros de teste
INSERT INTO livro (titulo, autor, isbn, editora, ano_publicacao, quantidade_total, quantidade_disponivel) VALUES
('Clean Code', 'Robert C. Martin', '978-0132350884', 'Prentice Hall', 2008, 5, 5),
('Design Patterns', 'Erich Gamma', '978-0201633610', 'Addison-Wesley', 1994, 3, 3),
('Java Como Programar', 'Paul Deitel', '978-8543004792', 'Bookman', 2016, 4, 4),
('Algoritmos', 'Thomas Cormen', '978-8535236996', 'Campus', 2012, 2, 2),
('Banco de Dados', 'Ramez Elmasri', '978-8579361074', 'Pearson', 2011, 3, 3);

-- ============================================================================
-- VIEWS ÚTEIS
-- ============================================================================

-- View para visualizar empréstimos com dados completos
CREATE VIEW vw_emprestimos_completos AS
SELECT 
    e.id,
    e.data_emprestimo,
    e.data_devolucao_prevista,
    e.data_devolucao_real,
    e.status,
    u.nome AS usuario_nome,
    u.email AS usuario_email,
    l.titulo AS livro_titulo,
    l.autor AS livro_autor,
    l.isbn AS livro_isbn,
    DATEDIFF(e.data_devolucao_prevista, CURDATE()) AS dias_restantes
FROM emprestimo e
INNER JOIN usuario u ON e.usuario_id = u.id
INNER JOIN livro l ON e.livro_id = l.id;

-- View para livros disponíveis
CREATE VIEW vw_livros_disponiveis AS
SELECT 
    l.id,
    l.titulo,
    l.autor,
    l.isbn,
    l.editora,
    l.ano_publicacao,
    l.quantidade_total,
    l.quantidade_disponivel,
    (l.quantidade_total - l.quantidade_disponivel) AS quantidade_emprestada
FROM livro l
WHERE l.quantidade_disponivel > 0;

-- ============================================================================
-- TRIGGERS
-- ============================================================================

-- Trigger para atualizar quantidade disponível ao emprestar
DELIMITER //
CREATE TRIGGER trg_emprestar_livro
AFTER INSERT ON emprestimo
FOR EACH ROW
BEGIN
    IF NEW.status = 'ATIVO' THEN
        UPDATE livro 
        SET quantidade_disponivel = quantidade_disponivel - 1
        WHERE id = NEW.livro_id;
    END IF;
END//
DELIMITER ;

-- Trigger para atualizar quantidade disponível ao devolver
DELIMITER //
CREATE TRIGGER trg_devolver_livro
AFTER UPDATE ON emprestimo
FOR EACH ROW
BEGIN
    IF OLD.status = 'ATIVO' AND NEW.status = 'DEVOLVIDO' THEN
        UPDATE livro 
        SET quantidade_disponivel = quantidade_disponivel + 1
        WHERE id = NEW.livro_id;
    END IF;
END//
DELIMITER ;

-- ============================================================================
-- PROCEDURES
-- ============================================================================

-- Procedure para realizar empréstimo
DELIMITER //
CREATE PROCEDURE sp_realizar_emprestimo(
    IN p_usuario_id BIGINT,
    IN p_livro_id BIGINT,
    IN p_dias_emprestimo INT
)
BEGIN
    DECLARE v_quantidade_disponivel INT;

    -- Verifica se o livro está disponível
    SELECT quantidade_disponivel INTO v_quantidade_disponivel
    FROM livro WHERE id = p_livro_id;

    IF v_quantidade_disponivel > 0 THEN
        INSERT INTO emprestimo (usuario_id, livro_id, data_emprestimo, data_devolucao_prevista, status)
        VALUES (p_usuario_id, p_livro_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL p_dias_emprestimo DAY), 'ATIVO');

        SELECT 'Empréstimo realizado com sucesso!' AS mensagem;
    ELSE
        SELECT 'Livro indisponível para empréstimo!' AS mensagem;
    END IF;
END//
DELIMITER ;

-- Procedure para realizar devolução
DELIMITER //
CREATE PROCEDURE sp_realizar_devolucao(
    IN p_emprestimo_id BIGINT
)
BEGIN
    UPDATE emprestimo 
    SET data_devolucao_real = CURDATE(),
        status = 'DEVOLVIDO'
    WHERE id = p_emprestimo_id AND status = 'ATIVO';

    SELECT 'Devolução realizada com sucesso!' AS mensagem;
END//
DELIMITER ;

-- ============================================================================
-- CONSULTAS ÚTEIS
-- ============================================================================

-- Listar empréstimos ativos
-- SELECT * FROM vw_emprestimos_completos WHERE status = 'ATIVO';

-- Listar livros disponíveis
-- SELECT * FROM vw_livros_disponiveis;

-- Listar empréstimos atrasados
-- SELECT * FROM vw_emprestimos_completos 
-- WHERE status = 'ATIVO' AND dias_restantes < 0;

-- Histórico de empréstimos de um usuário
-- SELECT * FROM vw_emprestimos_completos WHERE usuario_email = 'joao@email.com';

-- ============================================================================