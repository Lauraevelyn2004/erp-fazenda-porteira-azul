
def call_procedure(db, procedure_name, args=None):
    """
    Executa uma stored procedure e retorna os resultados.
    
    Args:
        db: Conexão com o banco (de get_db())
        procedure_name: Nome da procedure
        args: Tupla de argumentos para a procedure (opcional)
    
    Returns:
        Lista de dicionários com os resultados
    """
    try:
        cursor = db.cursor()
        
        if args:
            cursor.callproc(procedure_name, args)
        else:
            cursor.callproc(procedure_name)
        
        results = cursor.fetchall()
        cursor.close()
        return results
    
    except Exception as err:
        raise Exception(f"Erro ao executar procedure {procedure_name}: {err}")


def call_procedure_with_commit(db, procedure_name, args=None):
    """
    Executa uma stored procedure que modifica dados (INSERT, UPDATE, DELETE)
    e faz commit automático.
    
    Args:
        db: Conexão com o banco
        procedure_name: Nome da procedure
        args: Tupla de argumentos para a procedure
    
    Returns:
        True se bem-sucedido, False caso contrário
    """
    try:
        cursor = db.cursor()
        
        if args:
            cursor.callproc(procedure_name, args)
        else:
            cursor.callproc(procedure_name)
        
        db.commit()
        cursor.close()
        return True
    
    except Exception as err:
        db.rollback()
        raise Exception(f"Erro ao executar procedure {procedure_name}: {err}")
        return False


# =====================
# FUNÇÕES PARA FUNCIONÁRIOS
# =====================

def listar_funcionarios(db):
    """Lista todos os funcionários"""
    return call_procedure(db, 'sp_select_all_funcionarios')


def obter_funcionario(db, funcionario_id):
    """Obtém um funcionário específico por ID"""
    resultado = call_procedure(db, 'sp_select_funcionario_by_id', [funcionario_id])
    return resultado[0] if resultado else None


def inserir_funcionario(db, nome, funcao, salario, data_admissao):
    """Insere um novo funcionário"""
    return call_procedure_with_commit(
        db,
        'sp_insert_funcionario',
        [nome, funcao, salario, data_admissao]
    )


def atualizar_funcionario(db, funcionario_id, nome, funcao, salario, data_admissao):
    """Atualiza dados de um funcionário"""
    return call_procedure_with_commit(
        db,
        'sp_update_funcionario',
        [funcionario_id, nome, funcao, salario, data_admissao]
    )


def deletar_funcionario(db, funcionario_id):
    """Deleta um funcionário"""
    return call_procedure_with_commit(db, 'sp_delete_funcionario', [funcionario_id])


# =====================
# FUNÇÕES PARA MAQUINÁRIO
# =====================

def listar_maquinarios(db):
    """Lista todos os maquinários"""
    return call_procedure(db, 'sp_select_all_maquinarios')


def obter_maquinario(db, maquinario_id):
    """Obtém um maquinário específico por ID"""
    resultado = call_procedure(db, 'sp_select_maquinario_by_id', [maquinario_id])
    return resultado[0] if resultado else None


def inserir_maquinario(db, tipo, modelo, status, data_aquisicao, funcionario_id=None):
    """Insere um novo maquinário"""
    return call_procedure_with_commit(
        db,
        'sp_insert_maquinario',
        [tipo, modelo, status, data_aquisicao, funcionario_id]
    )


def atualizar_maquinario(db, maquinario_id, tipo, modelo, status, data_aquisicao, funcionario_id=None):
    """Atualiza dados de um maquinário"""
    return call_procedure_with_commit(
        db,
        'sp_update_maquinario',
        [maquinario_id, tipo, modelo, status, data_aquisicao, funcionario_id]
    )


def deletar_maquinario(db, maquinario_id):
    """Deleta um maquinário"""
    return call_procedure_with_commit(db, 'sp_delete_maquinario', [maquinario_id])


def listar_maquinarios_por_status(db, status):
    """Lista maquinários filtrados por status"""
    return call_procedure(db, 'sp_select_maquinarios_by_status', [status])


# =====================
# FUNÇÕES PARA ESTOQUE
# =====================
def listar_estoques(db):
    """Lista todos os estoques"""
    return call_procedure(db, 'sp_select_all_estoques')

def obter_estoque(db, estoque_id):
    """Obtém um estoque específico por ID"""
    resultado = call_procedure(db, 'sp_select_estoque_by_id', [estoque_id])
    return resultado[0] if resultado else None

def inserir_estoque(db, produto, quantidade, local_armazenamento):
    """Insere um novo estoque"""
    return call_procedure_with_commit(
        db,
        'sp_insert_estoque_producao',
        [produto, quantidade, local_armazenamento]
    )

def atualizar_estoque(db, estoque_id, produto, quantidade, local_armazenamento):
    """Atualiza dados de um estoque"""
    return call_procedure_with_commit(
        db,
        'sp_update_estoque_producao',
        [estoque_id, produto, quantidade, local_armazenamento]
    )

def deletar_estoque(db, estoque_id):
    """Deleta um estoque"""
    return call_procedure_with_commit(db, 'sp_delete_estoque_producao', [estoque_id])

def listar_estoque_por_produto(db, produto):
    """Lista estoque filtrado por produto (café, soja, milho)"""
    return call_procedure(db, 'sp_select_estoque_by_produto', [produto])

# =====================
# FUNÇÕES PARA MTD (Módulo de Tomada de Decisão)
# =====================

def listar_mtd(db):
    """Lista todos os dados do módulo de tomada de decisão"""
    return call_procedure(db, 'sp_select_all_mtd')


def obter_mtd_por_produto(db, produto):
    """Obtém dados MTD de um produto específico"""
    resultado = call_procedure(db, 'sp_select_mtd_by_produto', [produto])
    return resultado[0] if resultado else None


def inserir_mtd(db, produto, custo_por_saca, margem, sazonalidade, recomendacao):
    """Insere novo registro de MTD"""
    return call_procedure_with_commit(
        db,
        'sp_insert_mtd',
        [produto, custo_por_saca, margem, sazonalidade, recomendacao]
    )


def atualizar_mtd(db, mtd_id, produto, custo_por_saca, margem, sazonalidade, recomendacao):
    """Atualiza registro de MTD"""
    return call_procedure_with_commit(
        db,
        'sp_update_mtd',
        [mtd_id, produto, custo_por_saca, margem, sazonalidade, recomendacao]
    )


def calcular_preco_sugerido(db, produto):
    """Calcula o preço sugerido para venda de um produto"""
    resultado = call_procedure(db, 'sp_calcular_preco_sugerido', [produto])
    return resultado[0] if resultado else None


# =====================
# FUNÇÕES PARA DASHBOARD
# =====================

def obter_resumo_dashboard(db):
    """Obtém dados resumidos para o dashboard"""
    resultado = call_procedure(db, 'sp_dashboard_resumo')
    return resultado[0] if resultado else {}


def obter_relatorio_estoque_baixo(db, limite_minimo=1000):
    """Obtém relatório de itens com estoque abaixo do limite"""
    return call_procedure(db, 'sp_relatorio_estoque_baixo', [limite_minimo])


def obter_analise_vendas_mensal(db, ano, mes):
    """Obtém análise de vendas de um mês específico"""
    return call_procedure(db, 'sp_analise_vendas_mensal', [ano, mes])


# =====================
# FUNÇÕES PARA VENDAS
# =====================

def registrar_venda(db, estoque_id, quantidade, preco_venda, data_venda):
    """Registra uma nova venda"""
    return call_procedure_with_commit(
        db,
        'sp_insert_venda',
        [estoque_id, quantidade, preco_venda, data_venda]
    )


def listar_vendas(db):
    """Lista todas as vendas realizadas"""
    return call_procedure(db, 'sp_select_all_vendas')


# =====================
# FUNÇÕES PARA MOVIMENTAÇÃO DE ESTOQUE
# =====================

def registrar_movimentacao_estoque(db, estoque_id, funcionario_id, tipo_movimentacao, quantidade, data_movimentacao):
    """Registra entrada, saída ou ajuste de estoque"""
    return call_procedure_with_commit(
        db,
        'sp_insert_movimentacao_estoque',
        [estoque_id, funcionario_id, tipo_movimentacao, quantidade, data_movimentacao]
    )


def listar_movimentacoes_estoque(db):
    """Lista todas as movimentações de estoque"""
    return call_procedure(db, 'sp_select_all_movimentacoes_estoque')