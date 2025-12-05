import pymysql
from . import utils
from flask import Blueprint, render_template, request, redirect, url_for, flash, session, g, jsonify
from app import get_db




bp = Blueprint('main', __name__)

@bp.route('/')
def home():
    return redirect(url_for('main.login'))

@bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form.get('usuario')
        senha = request.form.get('senha')
        db = get_db()
        cur = db.cursor()
        cur.execute("SELECT nome, senha_hash, permissao FROM usuario WHERE email = %s", (email,))
        result = cur.fetchone()
        cur.close()
        if result:
            nome = result.get('nome')
            senha_hash = result.get('senha_hash')
            permissao = result.get('permissao')
            if senha == senha_hash:
                session['usuario'] = nome
                session['permissao'] = permissao
                flash('Login realizado com sucesso!')
                return redirect(url_for('main.dashboard'))
        flash('Usuário ou senha incorretos.')
    return render_template('login.html')

@bp.route('/dashboard')
def dashboard():
    if 'usuario' in session:
        return render_template('dashboard.html', usuario=session['usuario'])
    return redirect(url_for('main.login'))

@bp.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('main.login'))







# =====================================================
# NOVAS ROTAS: FUNCIONÁRIOS
# =====================================================

@bp.route('/funcionarios')
def listar_funcionarios():
    """Lista todos os funcionários"""
    if 'usuario' not in session:
        return redirect(url_for('main.login'))
    
    db = get_db()
    funcionarios = utils.listar_funcionarios(db)
    
    return render_template('funcionarios/listar.html',
                         usuario=session['usuario'],
                         funcionarios=funcionarios)


@bp.route('/funcionarios/novo', methods=['GET', 'POST'])
def novo_funcionario():
    """Cria um novo funcionário"""
    if 'usuario' not in session:
        return redirect(url_for('main.login'))
    
    if request.method == 'POST':
        nome = request.form.get('nome')
        funcao = request.form.get('funcao')
        salario = request.form.get('salario')
        data_admissao = request.form.get('data_admissao')
        
        db = get_db()
        try:
            utils.inserir_funcionario(db, nome, funcao, salario, data_admissao)
            flash('Funcionário cadastrado com sucesso!', 'success')
            return redirect(url_for('main.listar_funcionarios'))
        except Exception as e:
            flash(f'Erro ao cadastrar: {str(e)}', 'danger')
    
    return render_template('funcionarios/novo.html', usuario=session['usuario'])


@bp.route('/funcionarios/<int:id>/editar', methods=['GET', 'POST'])
def editar_funcionario(id):
    """Edita um funcionário"""
    if 'usuario' not in session:
        return redirect(url_for('main.login'))
    
    db = get_db()
    
    if request.method == 'POST':
        nome = request.form.get('nome')
        funcao = request.form.get('funcao')
        salario = request.form.get('salario')
        data_admissao = request.form.get('data_admissao')
        
        try:
            utils.atualizar_funcionario(db, id, nome, funcao, salario, data_admissao)
            flash('Funcionário atualizado com sucesso!', 'success')
            return redirect(url_for('main.listar_funcionarios'))
        except Exception as e:
            flash(f'Erro ao atualizar: {str(e)}', 'danger')
    
    funcionario = utils.obter_funcionario(db, id)
    if not funcionario:
        flash('Funcionário não encontrado.', 'warning')
        return redirect(url_for('main.listar_funcionarios'))
    
    return render_template('funcionarios/editar.html',
                         usuario=session['usuario'],
                         funcionario=funcionario)


@bp.route('/funcionarios/<int:id>/deletar')
def deletar_funcionario(id):
    """Deleta um funcionário"""
    if 'usuario' not in session:
        return redirect(url_for('main.login'))
    
    db = get_db()
    try:
        utils.deletar_funcionario(db, id)
        flash('Funcionário deletado com sucesso!', 'success')
    except Exception as e:
        flash(f'Erro ao deletar: {str(e)}', 'danger')
    
    return redirect(url_for('main.listar_funcionarios'))


# =====================================================
# NOVAS ROTAS: MAQUINÁRIO
# =====================================================

@bp.route('/maquinario')
def listar_maquinarios():
    """Lista todos os maquinários"""
    if 'usuario' not in session:
        return redirect(url_for('main.login'))
    
    db = get_db()
    maquinarios = utils.listar_maquinarios(db)
    
    return render_template('maquinario/listar.html',
                         usuario=session['usuario'],
                         maquinarios=maquinarios)


@bp.route('/maquinario/novo', methods=['GET', 'POST'])
def novo_maquinario():
    """Cria um novo maquinário"""
    if 'usuario' not in session:
        return redirect(url_for('main.login'))
    
    db = get_db()
    
    if request.method == 'POST':
        tipo = request.form.get('tipo')
        modelo = request.form.get('modelo')
        status = request.form.get('status')
        data_aquisicao = request.form.get('data_aquisicao')
        funcionario_id = request.form.get('funcionario_id') or None
        
        try:
            utils.inserir_maquinario(db, tipo, modelo, status, data_aquisicao, funcionario_id)
            flash('Maquinário cadastrado com sucesso!', 'success')
            return redirect(url_for('main.listar_maquinarios'))
        except Exception as e:
            flash(f'Erro ao cadastrar: {str(e)}', 'danger')
    
    funcionarios = utils.listar_funcionarios(db)
    return render_template('maquinario/novo.html',
                         usuario=session['usuario'],
                         funcionarios=funcionarios)
@bp.route('/maquinario/<int:id>/editar', methods=['GET', 'POST'])
def editar_maquinario(id):
    """Edita um maquinário"""
    if 'usuario' not in session:
        return redirect(url_for('main.login'))

    db = get_db()
    if request.method == 'POST':
        tipo = request.form.get('tipo')
        modelo = request.form.get('modelo')
        status = request.form.get('status')
        data_aquisicao = request.form.get('data_aquisicao')
        funcionario_id = request.form.get('funcionario_id') or None

        try:
            utils.atualizar_maquinario(db, id, tipo, modelo, status, data_aquisicao, funcionario_id)
            flash('Maquinário atualizado com sucesso!', 'success')
            return redirect(url_for('main.listar_maquinarios'))
        except Exception as e:
            flash(f'Erro ao atualizar: {str(e)}', 'danger')

    maquinario = utils.obter_maquinario(db, id)
    funcionarios = utils.listar_funcionarios(db)
    if not maquinario:
        flash('Maquinário não encontrado.', 'warning')
        return redirect(url_for('main.listar_maquinarios'))

    return render_template('maquinario/novo.html',
                           usuario=session['usuario'],
                           maquinario=maquinario,
                           funcionarios=funcionarios)

@bp.route('/maquinario/<int:id>/deletar')
def deletar_maquinario(id):
    """Deleta um maquinário"""
    if 'usuario' not in session:
        return redirect(url_for('main.login'))

    db = get_db()
    try:
        utils.deletar_maquinario(db, id)
        flash('Maquinário deletado com sucesso!', 'success')
    except Exception as e:
        flash(f'Erro ao deletar: {str(e)}', 'danger')
    
    return redirect(url_for('main.listar_maquinarios'))


# =====================================================
# NOVAS ROTAS: ESTOQUE
# =====================================================
@bp.route('/estoque')
def listar_estoques():
    """Lista todos os estoques"""
    
    if 'usuario' not in session:
        return redirect(url_for('main.login'))
    
    db = get_db()
    estoques = utils.listar_estoques(db)
    
    return render_template('estoque/listar.html',
                           usuario=session['usuario'],
                           estoques=estoques)


@bp.route('/estoque/novo', methods=['GET', 'POST'])
def novo_estoque():
    """Cria um novo estoque"""
    if 'usuario' not in session:
        return redirect(url_for('main.login'))
    
    if request.method == 'POST':
        produto = request.form.get('produto')
        quantidade = request.form.get('quantidade')
        local_armazenamento = request.form.get('local_armazenamento')
        
        db = get_db()
        try:
            utils.inserir_estoque(db, produto, quantidade, local_armazenamento)
            flash('Estoque cadastrado com sucesso!', 'success')
            return redirect(url_for('main.listar_estoques'))
        except Exception as e:
            flash(f'Erro ao cadastrar: {str(e)}', 'danger')
    
    return render_template('estoque/novo.html', usuario=session['usuario'])


@bp.route('/estoque/<int:id>/editar', methods=['GET', 'POST'])
def editar_estoque(id):
    """Edita um estoque"""
    if 'usuario' not in session:
        return redirect(url_for('main.login'))
    
    db = get_db()
    
    if request.method == 'POST':
        produto = request.form.get('produto')
        quantidade = request.form.get('quantidade')
        local_armazenamento = request.form.get('local_armazenamento')
        
        try:
            utils.atualizar_estoque(db, id, produto, quantidade, local_armazenamento)
            flash('Estoque atualizado com sucesso!', 'success')
            return redirect(url_for('main.listar_estoques'))
        except Exception as e:
            flash(f'Erro ao atualizar: {str(e)}', 'danger')
    
    estoque = utils.obter_estoque(db, id)
    if not estoque:
        flash('Estoque não encontrado.', 'warning')
        return redirect(url_for('main.listar_estoques'))
    
    return render_template('estoque/novo.html',
                           usuario=session['usuario'],
                           estoque=estoque)


@bp.route('/estoque/<int:id>/deletar')
def deletar_estoque(id):
    """Deleta um estoque"""
    if 'usuario' not in session:
        return redirect(url_for('main.login'))
    
    db = get_db()
    try:
        utils.deletar_estoque(db, id)
        flash('Estoque deletado com sucesso!', 'success')
    except Exception as e:
        flash(f'Erro ao deletar: {str(e)}', 'danger')
    
    return redirect(url_for('main.listar_estoques'))
# =====================================================
# MTD
# =====================================================
mtd_bp = Blueprint('mtd', __name__, url_prefix='/mtd')


@mtd_bp.route('/', methods=['GET'])
def mtd_dashboard():
    """Dashboard principal do MTD - exibe dados da tabela mtd"""
    try:
        db = get_db()
        cursor = db.cursor(pymysql.cursors.DictCursor)

        # Busca todos os registros de MTD
        cursor.callproc('sp_select_all_mtd')
        mtd_records = cursor.fetchall()

        # Busca estoque para contexto de decisão
        cursor.execute("""
            SELECT produto, SUM(quantidade) AS quantidade_total
            FROM estoque_producao
            GROUP BY produto
        """)
        estoque_info = {row['produto']: row['quantidade_total'] for row in cursor.fetchall()}

        cursor.close()

        return render_template(
            'mtd/dashboard.html',
            mtd_records=mtd_records,
            estoque_info=estoque_info
        )
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@mtd_bp.route('/analise', methods=['GET'])
def mtd_analise():
    """Página de análise e apoio a decisão de venda"""
    try:
        db = get_db()
        cursor = db.cursor(pymysql.cursors.DictCursor)

        # Busca todos os registros de MTD
        cursor.callproc('sp_select_all_mtd')
        mtd_records = cursor.fetchall()

        # Busca informações de estoque
        cursor.execute("""
            SELECT id, produto, quantidade, local_armazenamento
            FROM estoque_producao
            ORDER BY produto
        """)
        estoques = cursor.fetchall()

        # Busca preços sugeridos para cada produto
        precos_sugeridos = {}
        for produto in ['cafe', 'soja', 'milho']:
            cursor.callproc('sp_calcular_preco_sugerido', [produto])
            resultado = cursor.fetchone()
            if resultado:
                precos_sugeridos[produto] = resultado

        # Busca últimas vendas para contexto
        cursor.execute("""
            SELECT e.produto, v.preco_venda, v.data_venda, v.quantidade
            FROM venda v
            INNER JOIN estoque_producao e ON v.estoque_id = e.id
            ORDER BY v.data_venda DESC
            LIMIT 10
        """)
        vendas_recentes = cursor.fetchall()

        cursor.close()

        return render_template(
            'mtd/analise.html',
            mtd_records=mtd_records,
            estoques=estoques,
            precos_sugeridos=precos_sugeridos,
            vendas_recentes=vendas_recentes
        )
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@mtd_bp.route('/api/atualizar', methods=['POST'])
def atualizar_mtd():
    """API para atualizar registros MTD"""
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor()

        cursor.callproc('sp_update_mtd', [
            data['id'],
            data['produto'],
            float(data['custo_por_saca']),
            float(data['margem']),
            data['sazonalidade'],
            data['recomendacao']
        ])

        db.commit()
        cursor.close()

        return jsonify({'success': True, 'message': 'MTD atualizado com sucesso'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@mtd_bp.route('/api/inserir', methods=['POST'])
def inserir_mtd():
    """API para inserir novo registro MTD"""
    try:
        data = request.json
        db = get_db()
        cursor = db.cursor()

        cursor.callproc('sp_insert_mtd', [
            data['produto'],
            float(data['custo_por_saca']),
            float(data['margem']),
            data['sazonalidade'],
            data['recomendacao']
        ])

        db.commit()
        cursor.close()

        return jsonify({'success': True, 'message': 'MTD inserido com sucesso'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@mtd_bp.route('/api/deletar/<int:mtd_id>', methods=['DELETE'])
def deletar_mtd(mtd_id):
    """API para deletar registro MTD"""
    try:
        db = get_db()
        cursor = db.cursor()

        cursor.callproc('sp_delete_mtd', [mtd_id])
        db.commit()

        cursor.close()

        return jsonify({'success': True, 'message': 'MTD deletado com sucesso'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@mtd_bp.route('/api/sugerir-venda/<produto>', methods=['GET'])
def sugerir_venda(produto):
    """API para sugerir decisão de venda baseada em MTD"""
    try:
        db = get_db()
        cursor = db.cursor(pymysql.cursors.DictCursor)

        # Busca informações do MTD
        cursor.callproc('sp_select_mtd_by_produto', [produto])
        mtd_info = cursor.fetchone()

        # Busca estoque disponível
        cursor.execute("""
            SELECT SUM(quantidade) AS total
            FROM estoque_producao
            WHERE produto = %s
        """, (produto,))
        estoque = cursor.fetchone()

        if not mtd_info:
            cursor.close()
            return jsonify({'error': 'Produto não encontrado no MTD'}), 404

        # Lógica de decisão
        decisao = determinar_decisao_venda(mtd_info, estoque)

        cursor.close()

        return jsonify(decisao)
    except Exception as e:
        return jsonify({'error': str(e)}), 500


def determinar_decisao_venda(mtd_info, estoque):
    """Determina a recomendação de venda baseado em MTD"""

    preco_sugerido = mtd_info['custo_por_saca'] * (1 + mtd_info['margem'])
    estoque_total = estoque['total'] or 0

    decisao = {
        'produto': mtd_info['produto'].upper(),
        'preco_sugerido': round(preco_sugerido, 2),
        'custo': mtd_info['custo_por_saca'],
        'margem': f"{mtd_info['margem']*100:.1f}%",
        'estoque_disponivel': estoque_total,
        'sazonalidade': mtd_info['sazonalidade'],
        'recomendacao_mtd': mtd_info['recomendacao'],
        'acao_recomendada': mtd_info['recomendacao'],
        'urgencia': 'ALTA' if estoque_total < 1000 else 'MÉDIA' if estoque_total < 3000 else 'BAIXA',
        'grafico_decisao': gerar_grafico_decisao(mtd_info, estoque_total)
    }

    return decisao


def gerar_grafico_decisao(mtd_info, estoque_total):
    """Gera dados para gráfico de decisão"""
    return {
        'titulo': f"Decisão de Venda - {mtd_info['produto'].upper()}",
        'fatores': {
            'estoque': {
                'valor': estoque_total,
                'peso': 'Alto' if estoque_total > 3000 else 'Médio' if estoque_total > 1000 else 'Baixo',
                'recomendacao': 'Pode vender' if estoque_total > 2000 else 'Cuidado com estoque'
            },
            'margem': {
                'valor': f"{mtd_info['margem']*100:.1f}%",
                'peso': 'Boa' if mtd_info['margem'] > 0.20 else 'Aceitável' if mtd_info['margem'] > 0.10 else 'Baixa',
                'recomendacao': 'Margem favorável' if mtd_info['margem'] > 0.20 else 'Avaliar mercado'
            },
            'sazonalidade': {
                'valor': mtd_info['sazonalidade'],
                'peso': 'Favorável' if 'alta' in mtd_info['sazonalidade'].lower()
                        else 'Desfavorável' if 'queda' in mtd_info['sazonalidade'].lower()
                        else 'Estável',
                'recomendacao': mtd_info['recomendacao']
            }
        }
    }
# =====================================================
# FIM DAS NOVAS ROTAS
# =====================================================
