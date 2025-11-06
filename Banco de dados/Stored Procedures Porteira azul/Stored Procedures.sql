-- ========================================
-- STORED PROCEDURES PARA ERP FAZENDA PORTEIRA AZUL
-- Autor: Sistema de Gerenciamento
-- Data: Novembro 2025
-- ========================================

USE erp_fazenda;

DELIMITER $$

-- ========================================
-- STORED PROCEDURES PARA TABELA: USUARIO
-- ========================================

-- Procedure: Inserir novo usuário
CREATE PROCEDURE sp_insert_usuario(
    IN p_nome VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_permissao VARCHAR(20),
    IN p_senha_hash VARCHAR(255)
)
BEGIN
    INSERT INTO usuario (nome, email, permissao, senha_hash)
    VALUES (p_nome, p_email, p_permissao, p_senha_hash);

    SELECT LAST_INSERT_ID() AS usuario_id;
END$$

-- Procedure: Atualizar usuário
CREATE PROCEDURE sp_update_usuario(
    IN p_id INT,
    IN p_nome VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_permissao VARCHAR(20),
    IN p_senha_hash VARCHAR(255)
)
BEGIN
    UPDATE usuario 
    SET nome = p_nome,
        email = p_email,
        permissao = p_permissao,
        senha_hash = p_senha_hash
    WHERE id = p_id;

    SELECT ROW_COUNT() AS rows_affected;
END$$

-- Procedure: Deletar usuário
CREATE PROCEDURE sp_delete_usuario(
    IN p_id INT
)
BEGIN
    DELETE FROM usuario WHERE id = p_id;
    SELECT ROW_COUNT() AS rows_affected;
END$$

-- Procedure: Buscar usuário por ID
CREATE PROCEDURE sp_select_usuario_by_id(
    IN p_id INT
)
BEGIN
    SELECT * FROM usuario WHERE id = p_id;
END$$

-- Procedure: Listar todos os usuários
CREATE PROCEDURE sp_select_all_usuarios()
BEGIN
    SELECT * FROM usuario ORDER BY nome;
END$$

-- Procedure: Buscar usuário por email
CREATE PROCEDURE sp_select_usuario_by_email(
    IN p_email VARCHAR(100)
)
BEGIN
    SELECT * FROM usuario WHERE email = p_email;
END$$

-- ========================================
-- STORED PROCEDURES PARA TABELA: FUNCIONARIO
-- ========================================

-- Procedure: Inserir novo funcionário
CREATE PROCEDURE sp_insert_funcionario(
    IN p_nome VARCHAR(100),
    IN p_funcao VARCHAR(50),
    IN p_salario DECIMAL(10,2),
    IN p_data_admissao DATE
)
BEGIN
    INSERT INTO funcionario (nome, funcao, salario, data_admissao)
    VALUES (p_nome, p_funcao, p_salario, p_data_admissao);

    SELECT LAST_INSERT_ID() AS funcionario_id;
END$$

-- Procedure: Atualizar funcionário
CREATE PROCEDURE sp_update_funcionario(
    IN p_id INT,
    IN p_nome VARCHAR(100),
    IN p_funcao VARCHAR(50),
    IN p_salario DECIMAL(10,2),
    IN p_data_admissao DATE
)
BEGIN
    UPDATE funcionario 
    SET nome = p_nome,
        funcao = p_funcao,
        salario = p_salario,
        data_admissao = p_data_admissao
    WHERE id = p_id;

    SELECT ROW_COUNT() AS rows_affected;
END$$

-- Procedure: Deletar funcionário
CREATE PROCEDURE sp_delete_funcionario(
    IN p_id INT
)
BEGIN
    -- Verifica se há maquinários associados
    DECLARE maq_count INT;
    SELECT COUNT(*) INTO maq_count FROM maquinario WHERE funcionario_id = p_id;

    IF maq_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é possível deletar funcionário com maquinários associados';
    ELSE
        DELETE FROM funcionario WHERE id = p_id;
        SELECT ROW_COUNT() AS rows_affected;
    END IF;
END$$

-- Procedure: Buscar funcionário por ID
CREATE PROCEDURE sp_select_funcionario_by_id(
    IN p_id INT
)
BEGIN
    SELECT * FROM funcionario WHERE id = p_id;
END$$

-- Procedure: Listar todos os funcionários
CREATE PROCEDURE sp_select_all_funcionarios()
BEGIN
    SELECT * FROM funcionario ORDER BY nome;
END$$

-- Procedure: Buscar funcionários por função
CREATE PROCEDURE sp_select_funcionarios_by_funcao(
    IN p_funcao VARCHAR(50)
)
BEGIN
    SELECT * FROM funcionario WHERE funcao = p_funcao ORDER BY nome;
END$$

-- ========================================
-- STORED PROCEDURES PARA TABELA: MAQUINARIO
-- ========================================

-- Procedure: Inserir novo maquinário
CREATE PROCEDURE sp_insert_maquinario(
    IN p_tipo VARCHAR(50),
    IN p_modelo VARCHAR(50),
    IN p_status VARCHAR(20),
    IN p_data_aquisicao DATE,
    IN p_funcionario_id INT
)
BEGIN
    INSERT INTO maquinario (tipo, modelo, status, data_aquisicao, funcionario_id)
    VALUES (p_tipo, p_modelo, p_status, p_data_aquisicao, p_funcionario_id);

    SELECT LAST_INSERT_ID() AS maquinario_id;
END$$

-- Procedure: Atualizar maquinário
CREATE PROCEDURE sp_update_maquinario(
    IN p_id INT,
    IN p_tipo VARCHAR(50),
    IN p_modelo VARCHAR(50),
    IN p_status VARCHAR(20),
    IN p_data_aquisicao DATE,
    IN p_funcionario_id INT
)
BEGIN
    UPDATE maquinario 
    SET tipo = p_tipo,
        modelo = p_modelo,
        status = p_status,
        data_aquisicao = p_data_aquisicao,
        funcionario_id = p_funcionario_id
    WHERE id = p_id;

    SELECT ROW_COUNT() AS rows_affected;
END$$

-- Procedure: Deletar maquinário
CREATE PROCEDURE sp_delete_maquinario(
    IN p_id INT
)
BEGIN
    DELETE FROM maquinario WHERE id = p_id;
    SELECT ROW_COUNT() AS rows_affected;
END$$

-- Procedure: Buscar maquinário por ID
CREATE PROCEDURE sp_select_maquinario_by_id(
    IN p_id INT
)
BEGIN
    SELECT m.*, f.nome AS funcionario_nome
    FROM maquinario m
    LEFT JOIN funcionario f ON m.funcionario_id = f.id
    WHERE m.id = p_id;
END$$

-- Procedure: Listar todos os maquinários
CREATE PROCEDURE sp_select_all_maquinarios()
BEGIN
    SELECT m.*, f.nome AS funcionario_nome
    FROM maquinario m
    LEFT JOIN funcionario f ON m.funcionario_id = f.id
    ORDER BY m.tipo, m.modelo;
END$$

-- Procedure: Buscar maquinários por status
CREATE PROCEDURE sp_select_maquinarios_by_status(
    IN p_status VARCHAR(20)
)
BEGIN
    SELECT m.*, f.nome AS funcionario_nome
    FROM maquinario m
    LEFT JOIN funcionario f ON m.funcionario_id = f.id
    WHERE m.status = p_status
    ORDER BY m.tipo, m.modelo;
END$$

-- Procedure: Atualizar status do maquinário
CREATE PROCEDURE sp_update_maquinario_status(
    IN p_id INT,
    IN p_status VARCHAR(20)
)
BEGIN
    UPDATE maquinario SET status = p_status WHERE id = p_id;
    SELECT ROW_COUNT() AS rows_affected;
END$$

-- ========================================
-- STORED PROCEDURES PARA TABELA: ESTOQUE_PRODUCAO
-- ========================================

-- Procedure: Inserir novo estoque
CREATE PROCEDURE sp_insert_estoque_producao(
    IN p_produto ENUM('cafe','soja','milho'),
    IN p_quantidade DECIMAL(10,2),
    IN p_local_armazenamento VARCHAR(100)
)
BEGIN
    INSERT INTO estoque_producao (produto, quantidade, local_armazenamento)
    VALUES (p_produto, p_quantidade, p_local_armazenamento);

    SELECT LAST_INSERT_ID() AS estoque_id;
END$$

-- Procedure: Atualizar estoque
CREATE PROCEDURE sp_update_estoque_producao(
    IN p_id INT,
    IN p_produto ENUM('cafe','soja','milho'),
    IN p_quantidade DECIMAL(10,2),
    IN p_local_armazenamento VARCHAR(100)
)
BEGIN
    UPDATE estoque_producao 
    SET produto = p_produto,
        quantidade = p_quantidade,
        local_armazenamento = p_local_armazenamento
    WHERE id = p_id;

    SELECT ROW_COUNT() AS rows_affected;
END$$

-- Procedure: Deletar estoque
CREATE PROCEDURE sp_delete_estoque_producao(
    IN p_id INT
)
BEGIN
    DELETE FROM estoque_producao WHERE id = p_id;
    SELECT ROW_COUNT() AS rows_affected;
END$$

-- Procedure: Buscar estoque por ID
CREATE PROCEDURE sp_select_estoque_by_id(
    IN p_id INT
)
BEGIN
    SELECT * FROM estoque_producao WHERE id = p_id;
END$$

-- Procedure: Listar todos os estoques
CREATE PROCEDURE sp_select_all_estoques()
BEGIN
    SELECT * FROM estoque_producao ORDER BY produto;
END$$

-- Procedure: Buscar estoque por produto
CREATE PROCEDURE sp_select_estoque_by_produto(
    IN p_produto ENUM('cafe','soja','milho')
)
BEGIN
    SELECT * FROM estoque_producao WHERE produto = p_produto;
END$$

-- Procedure: Atualizar quantidade do estoque
CREATE PROCEDURE sp_update_estoque_quantidade(
    IN p_id INT,
    IN p_quantidade DECIMAL(10,2)
)
BEGIN
    UPDATE estoque_producao SET quantidade = p_quantidade WHERE id = p_id;
    SELECT ROW_COUNT() AS rows_affected;
END$$

-- Procedure: Adicionar quantidade ao estoque
CREATE PROCEDURE sp_add_estoque_quantidade(
    IN p_id INT,
    IN p_quantidade DECIMAL(10,2)
)
BEGIN
    UPDATE estoque_producao 
    SET quantidade = quantidade + p_quantidade 
    WHERE id = p_id;
    SELECT ROW_COUNT() AS rows_affected;
END$$

-- Procedure: Subtrair quantidade do estoque
CREATE PROCEDURE sp_subtract_estoque_quantidade(
    IN p_id INT,
    IN p_quantidade DECIMAL(10,2)
)
BEGIN
    DECLARE estoque_atual DECIMAL(10,2);
    SELECT quantidade INTO estoque_atual FROM estoque_producao WHERE id = p_id;

    IF estoque_atual < p_quantidade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantidade insuficiente em estoque';
    ELSE
        UPDATE estoque_producao 
        SET quantidade = quantidade - p_quantidade 
        WHERE id = p_id;
        SELECT ROW_COUNT() AS rows_affected;
    END IF;
END$$

-- ========================================
-- STORED PROCEDURES PARA TABELA: VENDA
-- ========================================

-- Procedure: Inserir nova venda
CREATE PROCEDURE sp_insert_venda(
    IN p_estoque_id INT,
    IN p_quantidade DECIMAL(10,2),
    IN p_preco_venda DECIMAL(10,2),
    IN p_data_venda DATE
)
BEGIN
    DECLARE estoque_disponivel DECIMAL(10,2);

    -- Verifica disponibilidade em estoque
    SELECT quantidade INTO estoque_disponivel 
    FROM estoque_producao 
    WHERE id = p_estoque_id;

    IF estoque_disponivel < p_quantidade THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantidade insuficiente em estoque para realizar a venda';
    ELSE
        -- Insere a venda
        INSERT INTO venda (estoque_id, quantidade, preco_venda, data_venda)
        VALUES (p_estoque_id, p_quantidade, p_preco_venda, p_data_venda);

        -- Atualiza o estoque
        UPDATE estoque_producao 
        SET quantidade = quantidade - p_quantidade 
        WHERE id = p_estoque_id;

        SELECT LAST_INSERT_ID() AS venda_id;
    END IF;
END$$

-- Procedure: Atualizar venda
CREATE PROCEDURE sp_update_venda(
    IN p_id INT,
    IN p_estoque_id INT,
    IN p_quantidade DECIMAL(10,2),
    IN p_preco_venda DECIMAL(10,2),
    IN p_data_venda DATE
)
BEGIN
    UPDATE venda 
    SET estoque_id = p_estoque_id,
        quantidade = p_quantidade,
        preco_venda = p_preco_venda,
        data_venda = p_data_venda
    WHERE id = p_id;

    SELECT ROW_COUNT() AS rows_affected;
END$$

-- Procedure: Deletar venda (cancela venda e retorna ao estoque)
CREATE PROCEDURE sp_delete_venda(
    IN p_id INT
)
BEGIN
    DECLARE v_estoque_id INT;
    DECLARE v_quantidade DECIMAL(10,2);

    -- Busca informações da venda
    SELECT estoque_id, quantidade 
    INTO v_estoque_id, v_quantidade
    FROM venda WHERE id = p_id;

    -- Retorna quantidade ao estoque
    UPDATE estoque_producao 
    SET quantidade = quantidade + v_quantidade 
    WHERE id = v_estoque_id;

    -- Remove a venda
    DELETE FROM venda WHERE id = p_id;

    SELECT ROW_COUNT() AS rows_affected;
END$$

-- Procedure: Buscar venda por ID
CREATE PROCEDURE sp_select_venda_by_id(
    IN p_id INT
)
BEGIN
    SELECT v.*, e.produto, e.local_armazenamento,
           (v.quantidade * v.preco_venda) AS valor_total
    FROM venda v
    INNER JOIN estoque_producao e ON v.estoque_id = e.id
    WHERE v.id = p_id;
END$$

-- Procedure: Listar todas as vendas
CREATE PROCEDURE sp_select_all_vendas()
BEGIN
    SELECT v.*, e.produto, e.local_armazenamento,
           (v.quantidade * v.preco_venda) AS valor_total
    FROM venda v
    INNER JOIN estoque_producao e ON v.estoque_id = e.id
    ORDER BY v.data_venda DESC;
END$$

-- Procedure: Buscar vendas por período
CREATE PROCEDURE sp_select_vendas_by_periodo(
    IN p_data_inicio DATE,
    IN p_data_fim DATE
)
BEGIN
    SELECT v.*, e.produto, e.local_armazenamento,
           (v.quantidade * v.preco_venda) AS valor_total
    FROM venda v
    INNER JOIN estoque_producao e ON v.estoque_id = e.id
    WHERE v.data_venda BETWEEN p_data_inicio AND p_data_fim
    ORDER BY v.data_venda DESC;
END$$

-- Procedure: Relatório de vendas por produto
CREATE PROCEDURE sp_relatorio_vendas_produto(
    IN p_produto ENUM('cafe','soja','milho'),
    IN p_data_inicio DATE,
    IN p_data_fim DATE
)
BEGIN
    SELECT 
        e.produto,
        COUNT(v.id) AS total_vendas,
        SUM(v.quantidade) AS quantidade_total,
        SUM(v.quantidade * v.preco_venda) AS receita_total,
        AVG(v.preco_venda) AS preco_medio
    FROM venda v
    INNER JOIN estoque_producao e ON v.estoque_id = e.id
    WHERE e.produto = p_produto
      AND v.data_venda BETWEEN p_data_inicio AND p_data_fim
    GROUP BY e.produto;
END$$

-- ========================================
-- STORED PROCEDURES PARA TABELA: MTD (Módulo de Tomada de Decisão)
-- ========================================

-- Procedure: Inserir novo registro MTD
CREATE PROCEDURE sp_insert_mtd(
    IN p_produto ENUM('cafe','soja','milho'),
    IN p_custo_por_saca DECIMAL(10,2),
    IN p_margem DECIMAL(5,2),
    IN p_sazonalidade VARCHAR(100),
    IN p_recomendacao VARCHAR(100)
)
BEGIN
    INSERT INTO mtd (produto, custo_por_saca, margem, sazonalidade, recomendacao)
    VALUES (p_produto, p_custo_por_saca, p_margem, p_sazonalidade, p_recomendacao);

    SELECT LAST_INSERT_ID() AS mtd_id;
END$$

-- Procedure: Atualizar MTD
CREATE PROCEDURE sp_update_mtd(
    IN p_id INT,
    IN p_produto ENUM('cafe','soja','milho'),
    IN p_custo_por_saca DECIMAL(10,2),
    IN p_margem DECIMAL(5,2),
    IN p_sazonalidade VARCHAR(100),
    IN p_recomendacao VARCHAR(100)
)
BEGIN
    UPDATE mtd 
    SET produto = p_produto,
        custo_por_saca = p_custo_por_saca,
        margem = p_margem,
        sazonalidade = p_sazonalidade,
        recomendacao = p_recomendacao
    WHERE id = p_id;

    SELECT ROW_COUNT() AS rows_affected;
END$$

-- Procedure: Deletar MTD
CREATE PROCEDURE sp_delete_mtd(
    IN p_id INT
)
BEGIN
    DELETE FROM mtd WHERE id = p_id;
    SELECT ROW_COUNT() AS rows_affected;
END$$

-- Procedure: Buscar MTD por ID
CREATE PROCEDURE sp_select_mtd_by_id(
    IN p_id INT
)
BEGIN
    SELECT * FROM mtd WHERE id = p_id;
END$$

-- Procedure: Listar todos os MTDs
CREATE PROCEDURE sp_select_all_mtd()
BEGIN
    SELECT * FROM mtd ORDER BY produto;
END$$

-- Procedure: Buscar MTD por produto
CREATE PROCEDURE sp_select_mtd_by_produto(
    IN p_produto ENUM('cafe','soja','milho')
)
BEGIN
    SELECT * FROM mtd WHERE produto = p_produto;
END$$

-- Procedure: Calcular preço de venda sugerido
CREATE PROCEDURE sp_calcular_preco_sugerido(
    IN p_produto ENUM('cafe','soja','milho')
)
BEGIN
    SELECT 
        produto,
        custo_por_saca,
        margem,
        ROUND(custo_por_saca * (1 + margem), 2) AS preco_sugerido,
        sazonalidade,
        recomendacao
    FROM mtd 
    WHERE produto = p_produto;
END$$

-- ========================================
-- STORED PROCEDURES PARA TABELA: MOVIMENTACAO_ESTOQUE
-- ========================================

-- Procedure: Inserir nova movimentação
CREATE PROCEDURE sp_insert_movimentacao_estoque(
    IN p_estoque_id INT,
    IN p_funcionario_id INT,
    IN p_tipo_movimentacao ENUM('entrada','saida','ajuste'),
    IN p_quantidade DECIMAL(10,2),
    IN p_data_movimentacao DATE
)
BEGIN
    -- Insere a movimentação
    INSERT INTO movimentacao_estoque 
    (estoque_id, funcionario_id, tipo_movimentacao, quantidade, data_movimentacao)
    VALUES (p_estoque_id, p_funcionario_id, p_tipo_movimentacao, p_quantidade, p_data_movimentacao);

    -- Atualiza o estoque conforme o tipo de movimentação
    IF p_tipo_movimentacao = 'entrada' THEN
        UPDATE estoque_producao 
        SET quantidade = quantidade + p_quantidade 
        WHERE id = p_estoque_id;
    ELSEIF p_tipo_movimentacao = 'saida' THEN
        UPDATE estoque_producao 
        SET quantidade = quantidade - p_quantidade 
        WHERE id = p_estoque_id;
    ELSEIF p_tipo_movimentacao = 'ajuste' THEN
        UPDATE estoque_producao 
        SET quantidade = p_quantidade 
        WHERE id = p_estoque_id;
    END IF;

    SELECT LAST_INSERT_ID() AS movimentacao_id;
END$$

-- Procedure: Atualizar movimentação
CREATE PROCEDURE sp_update_movimentacao_estoque(
    IN p_id INT,
    IN p_estoque_id INT,
    IN p_funcionario_id INT,
    IN p_tipo_movimentacao ENUM('entrada','saida','ajuste'),
    IN p_quantidade DECIMAL(10,2),
    IN p_data_movimentacao DATE
)
BEGIN
    UPDATE movimentacao_estoque 
    SET estoque_id = p_estoque_id,
        funcionario_id = p_funcionario_id,
        tipo_movimentacao = p_tipo_movimentacao,
        quantidade = p_quantidade,
        data_movimentacao = p_data_movimentacao
    WHERE id = p_id;

    SELECT ROW_COUNT() AS rows_affected;
END$$

-- Procedure: Deletar movimentação
CREATE PROCEDURE sp_delete_movimentacao_estoque(
    IN p_id INT
)
BEGIN
    DELETE FROM movimentacao_estoque WHERE id = p_id;
    SELECT ROW_COUNT() AS rows_affected;
END$$

-- Procedure: Buscar movimentação por ID
CREATE PROCEDURE sp_select_movimentacao_by_id(
    IN p_id INT
)
BEGIN
    SELECT m.*, e.produto, f.nome AS funcionario_nome
    FROM movimentacao_estoque m
    INNER JOIN estoque_producao e ON m.estoque_id = e.id
    INNER JOIN funcionario f ON m.funcionario_id = f.id
    WHERE m.id = p_id;
END$$

-- Procedure: Listar todas as movimentações
CREATE PROCEDURE sp_select_all_movimentacoes()
BEGIN
    SELECT m.*, e.produto, f.nome AS funcionario_nome
    FROM movimentacao_estoque m
    INNER JOIN estoque_producao e ON m.estoque_id = e.id
    INNER JOIN funcionario f ON m.funcionario_id = f.id
    ORDER BY m.data_movimentacao DESC;
END$$

-- Procedure: Buscar movimentações por período
CREATE PROCEDURE sp_select_movimentacoes_by_periodo(
    IN p_data_inicio DATE,
    IN p_data_fim DATE
)
BEGIN
    SELECT m.*, e.produto, f.nome AS funcionario_nome
    FROM movimentacao_estoque m
    INNER JOIN estoque_producao e ON m.estoque_id = e.id
    INNER JOIN funcionario f ON m.funcionario_id = f.id
    WHERE m.data_movimentacao BETWEEN p_data_inicio AND p_data_fim
    ORDER BY m.data_movimentacao DESC;
END$$

-- Procedure: Buscar movimentações por funcionário
CREATE PROCEDURE sp_select_movimentacoes_by_funcionario(
    IN p_funcionario_id INT,
    IN p_data_inicio DATE,
    IN p_data_fim DATE
)
BEGIN
    SELECT m.*, e.produto, f.nome AS funcionario_nome
    FROM movimentacao_estoque m
    INNER JOIN estoque_producao e ON m.estoque_id = e.id
    INNER JOIN funcionario f ON m.funcionario_id = f.id
    WHERE m.funcionario_id = p_funcionario_id
      AND m.data_movimentacao BETWEEN p_data_inicio AND p_data_fim
    ORDER BY m.data_movimentacao DESC;
END$$

-- ========================================
-- STORED PROCEDURES ESPECIALIZADAS E RELATÓRIOS
-- ========================================

-- Procedure: Dashboard resumo geral
CREATE PROCEDURE sp_dashboard_resumo()
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM funcionario) AS total_funcionarios,
        (SELECT COUNT(*) FROM maquinario) AS total_maquinarios,
        (SELECT COUNT(*) FROM maquinario WHERE status = 'disponível') AS maquinarios_disponiveis,
        (SELECT COUNT(*) FROM maquinario WHERE status = 'manutenção') AS maquinarios_manutencao,
        (SELECT SUM(quantidade) FROM estoque_producao WHERE produto = 'cafe') AS estoque_cafe,
        (SELECT SUM(quantidade) FROM estoque_producao WHERE produto = 'soja') AS estoque_soja,
        (SELECT SUM(quantidade) FROM estoque_producao WHERE produto = 'milho') AS estoque_milho,
        (SELECT COUNT(*) FROM venda WHERE MONTH(data_venda) = MONTH(CURDATE()) 
         AND YEAR(data_venda) = YEAR(CURDATE())) AS vendas_mes_atual,
        (SELECT SUM(quantidade * preco_venda) FROM venda 
         WHERE MONTH(data_venda) = MONTH(CURDATE()) 
         AND YEAR(data_venda) = YEAR(CURDATE())) AS receita_mes_atual;
END$$

-- Procedure: Relatório de estoque baixo
CREATE PROCEDURE sp_relatorio_estoque_baixo(
    IN p_limite_minimo DECIMAL(10,2)
)
BEGIN
    SELECT 
        produto,
        SUM(quantidade) AS quantidade_total,
        COUNT(*) AS locais_armazenamento,
        p_limite_minimo AS limite_minimo,
        CASE 
            WHEN SUM(quantidade) < p_limite_minimo THEN 'CRÍTICO'
            WHEN SUM(quantidade) < (p_limite_minimo * 1.5) THEN 'ATENÇÃO'
            ELSE 'NORMAL'
        END AS status_estoque
    FROM estoque_producao
    GROUP BY produto
    HAVING SUM(quantidade) < (p_limite_minimo * 2)
    ORDER BY quantidade_total ASC;
END$$

-- Procedure: Relatório de produtividade por funcionário
CREATE PROCEDURE sp_relatorio_produtividade_funcionario(
    IN p_data_inicio DATE,
    IN p_data_fim DATE
)
BEGIN
    SELECT 
        f.id,
        f.nome,
        f.funcao,
        COUNT(m.id) AS total_movimentacoes,
        SUM(CASE WHEN m.tipo_movimentacao = 'entrada' THEN m.quantidade ELSE 0 END) AS total_entradas,
        SUM(CASE WHEN m.tipo_movimentacao = 'saida' THEN m.quantidade ELSE 0 END) AS total_saidas,
        SUM(CASE WHEN m.tipo_movimentacao = 'ajuste' THEN m.quantidade ELSE 0 END) AS total_ajustes
    FROM funcionario f
    LEFT JOIN movimentacao_estoque m ON f.id = m.funcionario_id
        AND m.data_movimentacao BETWEEN p_data_inicio AND p_data_fim
    GROUP BY f.id, f.nome, f.funcao
    ORDER BY total_movimentacoes DESC;
END$$

-- Procedure: Análise de vendas mensal
CREATE PROCEDURE sp_analise_vendas_mensal(
    IN p_ano INT,
    IN p_mes INT
)
BEGIN
    SELECT 
        e.produto,
        COUNT(v.id) AS numero_vendas,
        SUM(v.quantidade) AS quantidade_vendida,
        SUM(v.quantidade * v.preco_venda) AS receita_total,
        AVG(v.preco_venda) AS preco_medio,
        MIN(v.preco_venda) AS preco_minimo,
        MAX(v.preco_venda) AS preco_maximo
    FROM venda v
    INNER JOIN estoque_producao e ON v.estoque_id = e.id
    WHERE YEAR(v.data_venda) = p_ano 
      AND MONTH(v.data_venda) = p_mes
    GROUP BY e.produto
    ORDER BY receita_total DESC;
END$$

-- Procedure: Histórico completo de um produto
CREATE PROCEDURE sp_historico_produto(
    IN p_produto ENUM('cafe','soja','milho'),
    IN p_data_inicio DATE,
    IN p_data_fim DATE
)
BEGIN
    -- Movimentações
    SELECT 
        'Movimentação' AS tipo,
        m.data_movimentacao AS data,
        m.tipo_movimentacao AS descricao,
        m.quantidade,
        NULL AS preco_unitario,
        NULL AS valor_total,
        f.nome AS responsavel
    FROM movimentacao_estoque m
    INNER JOIN estoque_producao e ON m.estoque_id = e.id
    INNER JOIN funcionario f ON m.funcionario_id = f.id
    WHERE e.produto = p_produto
      AND m.data_movimentacao BETWEEN p_data_inicio AND p_data_fim

    UNION ALL

    -- Vendas
    SELECT 
        'Venda' AS tipo,
        v.data_venda AS data,
        'Venda de produto' AS descricao,
        v.quantidade,
        v.preco_venda AS preco_unitario,
        (v.quantidade * v.preco_venda) AS valor_total,
        NULL AS responsavel
    FROM venda v
    INNER JOIN estoque_producao e ON v.estoque_id = e.id
    WHERE e.produto = p_produto
      AND v.data_venda BETWEEN p_data_inicio AND p_data_fim

    ORDER BY data DESC;
END$$

-- Procedure: Validar estoque antes de venda
CREATE PROCEDURE sp_validar_estoque_venda(
    IN p_produto ENUM('cafe','soja','milho'),
    IN p_quantidade DECIMAL(10,2)
)
BEGIN
    DECLARE total_disponivel DECIMAL(10,2);

    SELECT SUM(quantidade) INTO total_disponivel
    FROM estoque_producao
    WHERE produto = p_produto;

    SELECT 
        p_produto AS produto,
        p_quantidade AS quantidade_solicitada,
        COALESCE(total_disponivel, 0) AS quantidade_disponivel,
        CASE 
            WHEN COALESCE(total_disponivel, 0) >= p_quantidade THEN 'DISPONÍVEL'
            WHEN COALESCE(total_disponivel, 0) > 0 THEN 'PARCIALMENTE DISPONÍVEL'
            ELSE 'INDISPONÍVEL'
        END AS status,
        CASE 
            WHEN COALESCE(total_disponivel, 0) >= p_quantidade THEN 0
            ELSE p_quantidade - COALESCE(total_disponivel, 0)
        END AS deficit
    FROM DUAL;
END$$

-- Procedure: Relatório financeiro geral
CREATE PROCEDURE sp_relatorio_financeiro(
    IN p_data_inicio DATE,
    IN p_data_fim DATE
)
BEGIN
    SELECT 
        'Receita de Vendas' AS categoria,
        SUM(v.quantidade * v.preco_venda) AS valor
    FROM venda v
    WHERE v.data_venda BETWEEN p_data_inicio AND p_data_fim

    UNION ALL

    SELECT 
        'Folha de Pagamento' AS categoria,
        SUM(f.salario) * DATEDIFF(p_data_fim, p_data_inicio) / 30 AS valor
    FROM funcionario f
    WHERE f.data_admissao <= p_data_fim;
END$$

-- Procedure: Alocar maquinário para funcionário
CREATE PROCEDURE sp_alocar_maquinario(
    IN p_maquinario_id INT,
    IN p_funcionario_id INT
)
BEGIN
    DECLARE maq_status VARCHAR(20);

    SELECT status INTO maq_status FROM maquinario WHERE id = p_maquinario_id;

    IF maq_status = 'manutenção' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Maquinário em manutenção não pode ser alocado';
    ELSE
        UPDATE maquinario 
        SET funcionario_id = p_funcionario_id 
        WHERE id = p_maquinario_id;

        SELECT ROW_COUNT() AS rows_affected;
    END IF;
END$$

-- ========================================
-- MÓDULO: MTD (Módulo de Tomada de Decisão)
-- ========================================

CREATE PROCEDURE sp_insert_mtd(
    IN p_produto ENUM('cafe','soja','milho'),
    IN p_custo_por_saca DECIMAL(10,2),
    IN p_margem DECIMAL(5,2),
    IN p_sazonalidade VARCHAR(100),
    IN p_recomendacao VARCHAR(100)
)
BEGIN
    INSERT INTO mtd (produto, custo_por_saca, margem, sazonalidade, recomendacao)
    VALUES (p_produto, p_custo_por_saca, p_margem, p_sazonalidade, p_recomendacao);

    SELECT LAST_INSERT_ID() AS mtd_id;
END$$

CREATE PROCEDURE sp_update_mtd(
    IN p_id INT,
    IN p_produto ENUM('cafe','soja','milho'),
    IN p_custo_por_saca DECIMAL(10,2),
    IN p_margem DECIMAL(5,2),
    IN p_sazonalidade VARCHAR(100),
    IN p_recomendacao VARCHAR(100)
)
BEGIN
    UPDATE mtd 
    SET produto = p_produto,
        custo_por_saca = p_custo_por_saca,
        margem = p_margem,
        sazonalidade = p_sazonalidade,
        recomendacao = p_recomendacao
    WHERE id = p_id;

    SELECT ROW_COUNT() AS rows_affected;
END$$

CREATE PROCEDURE sp_delete_mtd(
    IN p_id INT
)
BEGIN
    DELETE FROM mtd WHERE id = p_id;
    SELECT ROW_COUNT() AS rows_affected;
END$$

CREATE PROCEDURE sp_select_mtd_by_id(
    IN p_id INT
)
BEGIN
    SELECT * FROM mtd WHERE id = p_id;
END$$

CREATE PROCEDURE sp_select_all_mtd()
BEGIN
    SELECT * FROM mtd ORDER BY produto;
END$$

CREATE PROCEDURE sp_select_mtd_by_produto(
    IN p_produto ENUM('cafe','soja','milho')
)
BEGIN
    SELECT * FROM mtd WHERE produto = p_produto;
END$$

CREATE PROCEDURE sp_calcular_preco_sugerido(
    IN p_produto ENUM('cafe','soja','milho')
)
BEGIN
    SELECT 
        produto,
        custo_por_saca,
        margem,
        ROUND(custo_por_saca * (1 + margem), 2) AS preco_sugerido,
        sazonalidade,
        recomendacao
    FROM mtd 
    WHERE produto = p_produto;
END$$

-- ========================================
-- MÓDULO: MOVIMENTAÇÃO DE ESTOQUE
-- ========================================

CREATE PROCEDURE sp_insert_movimentacao_estoque(
    IN p_estoque_id INT,
    IN p_funcionario_id INT,
    IN p_tipo_movimentacao ENUM('entrada','saida','ajuste'),
    IN p_quantidade DECIMAL(10,2),
    IN p_data_movimentacao DATE
)
BEGIN
    INSERT INTO movimentacao_estoque 
    (estoque_id, funcionario_id, tipo_movimentacao, quantidade, data_movimentacao)
    VALUES (p_estoque_id, p_funcionario_id, p_tipo_movimentacao, p_quantidade, p_data_movimentacao);

    IF p_tipo_movimentacao = 'entrada' THEN
        UPDATE estoque_producao 
        SET quantidade = quantidade + p_quantidade 
        WHERE id = p_estoque_id;
    ELSEIF p_tipo_movimentacao = 'saida' THEN
        UPDATE estoque_producao 
        SET quantidade = quantidade - p_quantidade 
        WHERE id = p_estoque_id;
    ELSEIF p_tipo_movimentacao = 'ajuste' THEN
        UPDATE estoque_producao 
        SET quantidade = p_quantidade 
        WHERE id = p_estoque_id;
    END IF;

    SELECT LAST_INSERT_ID() AS movimentacao_id;
END$$

CREATE PROCEDURE sp_update_movimentacao_estoque(
    IN p_id INT,
    IN p_estoque_id INT,
    IN p_funcionario_id INT,
    IN p_tipo_movimentacao ENUM('entrada','saida','ajuste'),
    IN p_quantidade DECIMAL(10,2),
    IN p_data_movimentacao DATE
)
BEGIN
    UPDATE movimentacao_estoque 
    SET estoque_id = p_estoque_id,
        funcionario_id = p_funcionario_id,
        tipo_movimentacao = p_tipo_movimentacao,
        quantidade = p_quantidade,
        data_movimentacao = p_data_movimentacao
    WHERE id = p_id;

    SELECT ROW_COUNT() AS rows_affected;
END$$

CREATE PROCEDURE sp_delete_movimentacao_estoque(
    IN p_id INT
)
BEGIN
    DELETE FROM movimentacao_estoque WHERE id = p_id;
    SELECT ROW_COUNT() AS rows_affected;
END$$

CREATE PROCEDURE sp_select_movimentacao_by_id(
    IN p_id INT
)
BEGIN
    SELECT m.*, e.produto, f.nome AS funcionario_nome
    FROM movimentacao_estoque m
    INNER JOIN estoque_producao e ON m.estoque_id = e.id
    INNER JOIN funcionario f ON m.funcionario_id = f.id
    WHERE m.id = p_id;
END$$

CREATE PROCEDURE sp_select_all_movimentacoes()
BEGIN
    SELECT m.*, e.produto, f.nome AS funcionario_nome
    FROM movimentacao_estoque m
    INNER JOIN estoque_producao e ON m.estoque_id = e.id
    INNER JOIN funcionario f ON m.funcionario_id = f.id
    ORDER BY m.data_movimentacao DESC;
END$$

CREATE PROCEDURE sp_select_movimentacoes_by_periodo(
    IN p_data_inicio DATE,
    IN p_data_fim DATE
)
BEGIN
    SELECT m.*, e.produto, f.nome AS funcionario_nome
    FROM movimentacao_estoque m
    INNER JOIN estoque_producao e ON m.estoque_id = e.id
    INNER JOIN funcionario f ON m.funcionario_id = f.id
    WHERE m.data_movimentacao BETWEEN p_data_inicio AND p_data_fim
    ORDER BY m.data_movimentacao DESC;
END$$

CREATE PROCEDURE sp_select_movimentacoes_by_funcionario(
    IN p_funcionario_id INT,
    IN p_data_inicio DATE,
    IN p_data_fim DATE
)
BEGIN
    SELECT m.*, e.produto, f.nome AS funcionario_nome
    FROM movimentacao_estoque m
    INNER JOIN estoque_producao e ON m.estoque_id = e.id
    INNER JOIN funcionario f ON m.funcionario_id = f.id
    WHERE m.funcionario_id = p_funcionario_id
      AND m.data_movimentacao BETWEEN p_data_inicio AND p_data_fim
    ORDER BY m.data_movimentacao DESC;
END$$

-- ========================================
-- MÓDULO: RELATÓRIOS E PROCEDURES ESPECIALIZADAS
-- ========================================

CREATE PROCEDURE sp_dashboard_resumo()
BEGIN
    SELECT 
        (SELECT COUNT(*) FROM funcionario) AS total_funcionarios,
        (SELECT COUNT(*) FROM maquinario) AS total_maquinarios,
        (SELECT COUNT(*) FROM maquinario WHERE status = 'disponível') AS maquinarios_disponiveis,
        (SELECT COUNT(*) FROM maquinario WHERE status = 'manutenção') AS maquinarios_manutencao,
        (SELECT SUM(quantidade) FROM estoque_producao WHERE produto = 'cafe') AS estoque_cafe,
        (SELECT SUM(quantidade) FROM estoque_producao WHERE produto = 'soja') AS estoque_soja,
        (SELECT SUM(quantidade) FROM estoque_producao WHERE produto = 'milho') AS estoque_milho,
        (SELECT COUNT(*) FROM venda WHERE MONTH(data_venda) = MONTH(CURDATE()) 
         AND YEAR(data_venda) = YEAR(CURDATE())) AS vendas_mes_atual,
        (SELECT SUM(quantidade * preco_venda) FROM venda 
         WHERE MONTH(data_venda) = MONTH(CURDATE()) 
         AND YEAR(data_venda) = YEAR(CURDATE())) AS receita_mes_atual;
END$$

CREATE PROCEDURE sp_relatorio_estoque_baixo(
    IN p_limite_minimo DECIMAL(10,2)
)
BEGIN
    SELECT 
        produto,
        SUM(quantidade) AS quantidade_total,
        COUNT(*) AS locais_armazenamento,
        p_limite_minimo AS limite_minimo,
        CASE 
            WHEN SUM(quantidade) < p_limite_minimo THEN 'CRÍTICO'
            WHEN SUM(quantidade) < (p_limite_minimo * 1.5) THEN 'ATENÇÃO'
            ELSE 'NORMAL'
        END AS status_estoque
    FROM estoque_producao
    GROUP BY produto
    HAVING SUM(quantidade) < (p_limite_minimo * 2)
    ORDER BY quantidade_total ASC;
END$$

CREATE PROCEDURE sp_relatorio_produtividade_funcionario(
    IN p_data_inicio DATE,
    IN p_data_fim DATE
)
BEGIN
    SELECT 
        f.id,
        f.nome,
        f.funcao,
        COUNT(m.id) AS total_movimentacoes,
        SUM(CASE WHEN m.tipo_movimentacao = 'entrada' THEN m.quantidade ELSE 0 END) AS total_entradas,
        SUM(CASE WHEN m.tipo_movimentacao = 'saida' THEN m.quantidade ELSE 0 END) AS total_saidas,
        SUM(CASE WHEN m.tipo_movimentacao = 'ajuste' THEN m.quantidade ELSE 0 END) AS total_ajustes
    FROM funcionario f
    LEFT JOIN movimentacao_estoque m ON f.id = m.funcionario_id
        AND m.data_movimentacao BETWEEN p_data_inicio AND p_data_fim
    GROUP BY f.id, f.nome, f.funcao
    ORDER BY total_movimentacoes DESC;
END$$

CREATE PROCEDURE sp_analise_vendas_mensal(
    IN p_ano INT,
    IN p_mes INT
)
BEGIN
    SELECT 
        e.produto,
        COUNT(v.id) AS numero_vendas,
        SUM(v.quantidade) AS quantidade_vendida,
        SUM(v.quantidade * v.preco_venda) AS receita_total,
        AVG(v.preco_venda) AS preco_medio,
        MIN(v.preco_venda) AS preco_minimo,
        MAX(v.preco_venda) AS preco_maximo
    FROM venda v
    INNER JOIN estoque_producao e ON v.estoque_id = e.id
    WHERE YEAR(v.data_venda) = p_ano 
      AND MONTH(v.data_venda) = p_mes
    GROUP BY e.produto
    ORDER BY receita_total DESC;
END$$

CREATE PROCEDURE sp_historico_produto(
    IN p_produto ENUM('cafe','soja','milho'),
    IN p_data_inicio DATE,
    IN p_data_fim DATE
)
BEGIN
    SELECT 
        'Movimentação' AS tipo,
        m.data_movimentacao AS data,
        m.tipo_movimentacao AS descricao,
        m.quantidade,
        NULL AS preco_unitario,
        NULL AS valor_total,
        f.nome AS responsavel
    FROM movimentacao_estoque m
    INNER JOIN estoque_producao e ON m.estoque_id = e.id
    INNER JOIN funcionario f ON m.funcionario_id = f.id
    WHERE e.produto = p_produto
      AND m.data_movimentacao BETWEEN p_data_inicio AND p_data_fim

    UNION ALL

    SELECT 
        'Venda' AS tipo,
        v.data_venda AS data,
        'Venda de produto' AS descricao,
        v.quantidade,
        v.preco_venda AS preco_unitario,
        (v.quantidade * v.preco_venda) AS valor_total,
        NULL AS responsavel
    FROM venda v
    INNER JOIN estoque_producao e ON v.estoque_id = e.id
    WHERE e.produto = p_produto
      AND v.data_venda BETWEEN p_data_inicio AND p_data_fim

    ORDER BY data DESC;
END$$

CREATE PROCEDURE sp_validar_estoque_venda(
    IN p_produto ENUM('cafe','soja','milho'),
    IN p_quantidade DECIMAL(10,2)
)
BEGIN
    DECLARE total_disponivel DECIMAL(10,2);

    SELECT SUM(quantidade) INTO total_disponivel
    FROM estoque_producao
    WHERE produto = p_produto;

    SELECT 
        p_produto AS produto,
        p_quantidade AS quantidade_solicitada,
        COALESCE(total_disponivel, 0) AS quantidade_disponivel,
        CASE 
            WHEN COALESCE(total_disponivel, 0) >= p_quantidade THEN 'DISPONÍVEL'
            WHEN COALESCE(total_disponivel, 0) > 0 THEN 'PARCIALMENTE DISPONÍVEL'
            ELSE 'INDISPONÍVEL'
        END AS status,
        CASE 
            WHEN COALESCE(total_disponivel, 0) >= p_quantidade THEN 0
            ELSE p_quantidade - COALESCE(total_disponivel, 0)
        END AS deficit
    FROM DUAL;
END$$

CREATE PROCEDURE sp_relatorio_financeiro(
    IN p_data_inicio DATE,
    IN p_data_fim DATE
)
BEGIN
    SELECT 
        'Receita de Vendas' AS categoria,
        SUM(v.quantidade * v.preco_venda) AS valor
    FROM venda v
    WHERE v.data_venda BETWEEN p_data_inicio AND p_data_fim

    UNION ALL

    SELECT 
        'Folha de Pagamento' AS categoria,
        SUM(f.salario) * DATEDIFF(p_data_fim, p_data_inicio) / 30 AS valor
    FROM funcionario f
    WHERE f.data_admissao <= p_data_fim;
END$$

CREATE PROCEDURE sp_alocar_maquinario(
    IN p_maquinario_id INT,
    IN p_funcionario_id INT
)
BEGIN
    DECLARE maq_status VARCHAR(20);

    SELECT status INTO maq_status FROM maquinario WHERE id = p_maquinario_id;

    IF maq_status = 'manutenção' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Maquinário em manutenção não pode ser alocado';
    ELSE
        UPDATE maquinario 
        SET funcionario_id = p_funcionario_id 
        WHERE id = p_maquinario_id;

        SELECT ROW_COUNT() AS rows_affected;
    END IF;
END$$

DELIMITER ;