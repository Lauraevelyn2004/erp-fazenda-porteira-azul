import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    """Configurações base da aplicação"""
    SECRET_KEY = os.getenv('SECRET_KEY', 'sua-chave-secreta-aqui')
    DEBUG = False
    TESTING = False
    
    # Configurações do banco MySQL
    MYSQL_HOST = os.getenv('MYSQL_HOST', 'localhost')
    MYSQL_USER = os.getenv('MYSQL_USER', 'root')
    MYSQL_PASSWORD = os.getenv('MYSQL_PASSWORD', '')
    MYSQL_DB = os.getenv('MYSQL_DB', 'erp_fazenda')
    MYSQL_CURSORCLASS = 'DictCursor'  # Retorna resultados como dicionário
    
    # Sessão
    SESSION_PERMANENT = False
    SESSION_TYPE = 'filesystem'


class DevelopmentConfig(Config):
    """Configurações para desenvolvimento"""
    DEBUG = True
    TESTING = False


class TestingConfig(Config):
    """Configurações para testes"""
    TESTING = True
    MYSQL_DB = 'erp_fazenda_test'


class ProductionConfig(Config):
    """Configurações para produção"""
    DEBUG = False
    TESTING = False


config = {
    'development': DevelopmentConfig,
    'testing': TestingConfig,
    'production': ProductionConfig,
    'default': DevelopmentConfig
}