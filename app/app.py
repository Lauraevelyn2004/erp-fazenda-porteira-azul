from flask import Flask
from app.routes import bp as main_bp

app = Flask(__name__)
app.secret_key = 'chave_secreta_aqui'  # Troque por valor seguro

app.register_blueprint(main_bp)

if __name__ == '__main__':
    app.run(debug=True)
