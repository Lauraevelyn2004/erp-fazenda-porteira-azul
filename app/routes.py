from flask import Blueprint, render_template, request, redirect, url_for, flash, session

bp = Blueprint('main', __name__)

def valida_login(usuario, senha):
    return usuario == 'admin' and senha == '123'

@bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        usuario = request.form.get('usuario')
        senha = request.form.get('senha')
        if valida_login(usuario, senha):
            session['usuario'] = usuario
            flash('Login realizado com sucesso!')
            return redirect(url_for('main.dashboard'))
        else:
            flash('Usuário ou senha incorretos.')
    return render_template('login.html')

@bp.route('/dashboard')
def dashboard():
    if 'usuario' in session:
        return render_template('dashboard.html', usuario=session['usuario'])
    else:
        return redirect(url_for('main.login'))

@bp.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('main.login'))