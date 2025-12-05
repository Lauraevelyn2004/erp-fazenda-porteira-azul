# routes/mtd.py - Rotas para o Módulo de Tomada de Decisão (MTD)

from flask import Blueprint, render_template, jsonify
from app import get_db
from app.utils import (
    listar_mtd,
    obter_mtd_por_produto,
    listar_estoques
)

bp = Blueprint('mtd', __name__, url_prefix='/mtd')

@bp.route('/')
def index():
    """Página principal do sistema de decisão de venda"""
    try:
        db = get_db()
        
        # Busca todos os dados de MTD
        mtd_dados = listar_mtd(db)
        
        # Busca todos os estoques
        estoques = listar_estoques(db)
        
        # Calcula métricas
        metricas = calcular_metricas(mtd_dados, estoques)
        
        return render_template('mtd/listar.html', 
                             mtd_dados=mtd_dados,
                             estoques=estoques,
                             metricas=metricas)
    except Exception as e:
        return render_template('mtd/listar.html', 
                             erro=f'Erro ao carregar dados: {str(e)}')

@bp.route('/api/dados')
def api_dados():
    """API para retornar dados em JSON (opcional para gráficos dinâmicos)"""
    try:
        db = get_db()
        
        mtd_dados = listar_mtd(db)
        
        # Formata dados para o gráfico
        dados_grafico = []
        for item in mtd_dados:
            # Busca estoque correspondente
            estoque_item = next(
                (e for e in listar_estoques(db) if e['produto'] == item['produto']),
                None
            )
            
            if estoque_item:
                dados_grafico.append({
                    'produto': item['produto'].upper(),
                    'quantidade': float(estoque_item['quantidade']),
                    'custo': float(item['custo_por_saca']),
                    'margem': float(item['margem']),
                    'preco_sugerido': calcular_preco_sugerido(
                        float(item['custo_por_saca']),
                        float(item['margem'])
                    ),
                    'sazonalidade': item['sazonalidade'],
                    'recomendacao': item['recomendacao']
                })
        
        return jsonify({'sucesso': True, 'dados': dados_grafico})
    except Exception as e:
        return jsonify({'sucesso': False, 'erro': str(e)})

# Funções auxiliares

def calcular_preco_sugerido(custo, margem):
    """Calcula o preço sugerido baseado no custo e margem"""
    return round(custo * (1 + margem), 2)

def obter_status_estoque(quantidade, limite_baixo=1000, limite_medio=3000):
    """Determina o status do estoque (Baixo, Médio, Alto)"""
    if quantidade < limite_baixo:
        return 'Baixo'
    elif quantidade < limite_medio:
        return 'Médio'
    else:
        return 'Alto'

def calcular_metricas(mtd_dados, estoques):
    """Calcula as métricas principais para a dashboard"""
    
    total_estoque = sum(e['quantidade'] for e in estoques)
    total_produtos = len(mtd_dados)
    
    # Calcula preço médio sugerido
    precos_sugeridos = [
        calcular_preco_sugerido(
            float(m['custo_por_saca']),
            float(m['margem'])
        ) for m in mtd_dados
    ]
    preco_medio = round(sum(precos_sugeridos) / len(precos_sugeridos), 2) if precos_sugeridos else 0
    
    # Calcula ocupação (aproximado: total_estoque / capacidade_maxima)
    capacidade_maxima = 10000  # Altere conforme sua capacidade
    ocupacao = round((total_estoque / capacidade_maxima) * 100, 1)
    
    return {
        'total_estoque': round(total_estoque, 2),
        'total_produtos': total_produtos,
        'preco_medio': preco_medio,
        'ocupacao': ocupacao
    }