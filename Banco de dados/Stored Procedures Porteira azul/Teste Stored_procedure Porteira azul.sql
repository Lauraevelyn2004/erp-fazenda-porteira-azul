USE erp_fazenda;

-- ========================================
-- SCRIPT DE VERIFICAÇÃO DAS PROCEDURES
-- Execute após instalar as procedures
-- ========================================

USE erp_fazenda;

-- 1. Contar total de procedures instaladas
SELECT 
    COUNT(*) AS total_procedures,
    'Procedures do sistema' AS descricao
FROM information_schema.ROUTINES 
WHERE ROUTINE_SCHEMA = 'erp_fazenda' 
  AND ROUTINE_TYPE = 'PROCEDURE';

-- 2. Listar todas as procedures
SELECT 
    ROUTINE_NAME,
    ROUTINE_TYPE,
    CREATED
FROM information_schema.ROUTINES 
WHERE ROUTINE_SCHEMA = 'erp_fazenda' 
  AND ROUTINE_TYPE = 'PROCEDURE'
ORDER BY ROUTINE_NAME;

-- 3. Contar por módulo
SELECT 
    CASE 
        WHEN ROUTINE_NAME LIKE 'sp_insert_mtd%' THEN 'MTD'
        WHEN ROUTINE_NAME LIKE 'sp_update_mtd%' THEN 'MTD'
        WHEN ROUTINE_NAME LIKE 'sp_delete_mtd%' THEN 'MTD'
        WHEN ROUTINE_NAME LIKE 'sp_select_mtd%' THEN 'MTD'
        WHEN ROUTINE_NAME LIKE 'sp_calcular_preco%' THEN 'MTD'
        WHEN ROUTINE_NAME LIKE 'sp_%movimentacao%' THEN 'Movimentação Estoque'
        WHEN ROUTINE_NAME LIKE 'sp_dashboard%' THEN 'Relatórios'
        WHEN ROUTINE_NAME LIKE 'sp_relatorio%' THEN 'Relatórios'
        WHEN ROUTINE_NAME LIKE 'sp_analise%' THEN 'Relatórios'
        WHEN ROUTINE_NAME LIKE 'sp_historico%' THEN 'Relatórios'
        WHEN ROUTINE_NAME LIKE 'sp_validar%' THEN 'Relatórios'
        WHEN ROUTINE_NAME LIKE 'sp_alocar%' THEN 'Relatórios'
        ELSE 'Outro'
    END AS modulo,
    COUNT(*) AS total
FROM information_schema.ROUTINES 
WHERE ROUTINE_SCHEMA = 'erp_fazenda' 
  AND ROUTINE_TYPE = 'PROCEDURE'
GROUP BY modulo
ORDER BY modulo;

-- 4. Testes rápidos das procedures
SELECT '========================================' AS '';
SELECT '✅ TESTES DAS PROCEDURES INSTALADAS' AS '';
SELECT '========================================' AS '';

-- Teste 1
SELECT '--- Teste 1: MTD ---' AS '';
CALL sp_select_all_mtd();

-- Teste 2
SELECT '--- Teste 2: Calcular Preço ---' AS '';
CALL sp_calcular_preco_sugerido('cafe');

-- Teste 3
SELECT '--- Teste 3: Dashboard Resumo ---' AS '';
CALL sp_dashboard_resumo();

-- Teste 4
SELECT '--- Teste 4: Estoque Baixo ---' AS '';
CALL sp_relatorio_estoque_baixo(1000.00);

-- Teste 5
SELECT '--- Teste 5: Listar Movimentações ---' AS '';
CALL sp_select_all_movimentacoes();

SELECT '========================================' AS '';
SELECT '✅ TODOS OS TESTES CONCLUÍDOS!' AS '';
SELECT '========================================' AS '';