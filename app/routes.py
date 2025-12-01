from . import utils
from flask import Blueprint, render_template, request, redirect, url_for, flash, session, g
from app import get_db  # importa a função get_db do __init__.py




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
# NOVAS ROTAS: MÓDULO DE TOMADA DE DECISÃO (MTD)
# =====================================================

@bp.route('/mtd')
def dashboard_mtd():
    """Dashboard do Módulo de Tomada de Decisão"""
    if 'usuario' not in session:
        return redirect(url_for('main.login'))
    
    db = get_db()
    mtd_dados = utils.listar_mtd(db)
    
    return render_template('mtd/dashboard.html',
                         usuario=session['usuario'],
                         mtd_dados=mtd_dados)


@bp.route('/mtd/analise/<produto>')
def analise_mtd(produto):
    """Análise detalhada de um produto no MTD"""
    if 'usuario' not in session:
        return redirect(url_for('main.login'))
    
    db = get_db()
    mtd_produto = utils.obter_mtd_por_produto(db, produto)
    preco_sugerido = utils.calcular_preco_sugerido(db, produto)
    
    return render_template('mtd/analise.html',
                         usuario=session['usuario'],
                         mtd_produto=mtd_produto,
                         preco_sugerido=preco_sugerido,
                         produto=produto)


# =====================================================
# FIM DAS NOVAS ROTAS
# =====================================================