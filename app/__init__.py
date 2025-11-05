import pymysql
from flask import Flask, g

app = Flask(__name__)
app.secret_key = 'de234f97d54b7d19cdc88524436bb232ad0d12eceb1a7737424b62ee19681795'

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''  # Coloque a senha correta aqui
app.config['MYSQL_DB'] = 'erp_fazenda'

def get_db():
    if 'db' not in g:
        g.db = pymysql.connect(
            host=app.config['MYSQL_HOST'],
            user=app.config['MYSQL_USER'],
            password=app.config['MYSQL_PASSWORD'],
            db=app.config['MYSQL_DB'],
            cursorclass=pymysql.cursors.DictCursor
        )
    return g.db

@app.teardown_appcontext
def close_db(error):
    db = g.pop('db', None)
    if db is not None:
        db.close()

# Importa as rotas após definir app e get_db
from app.routes import bp as mainbp
app.register_blueprint(mainbp)
