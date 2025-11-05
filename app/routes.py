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
