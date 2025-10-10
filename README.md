# 🌾 ERP Fazenda Porteira Azul

> **Projeto desenvolvido na disciplina de Sistemas de Apoio à Decisão**  
> **Curso:** Bacharelado em Sistemas de Informação  
> **Professor:** Fábio Corsini  
> **Instituição:** IFSULDEMINAS – Campus Machado  

---

## 🧭 Sobre o Projeto

A **Fazenda Porteira Azul** é uma propriedade rural que atua principalmente com **Cafeicultura**, e em menor escala com **Soja** e **Milho**.  
O objetivo deste projeto é desenvolver um **ERP (Sistema Integrado de Gestão)** que facilite o **gerenciamento de funcionários, maquinário, estoque de produção** e inclua um **Módulo de Tomada de Decisão (MTD)** para identificar o **melhor momento para vender os grãos**, maximizando o lucro com base em custos, margens e sazonalidade de preços.

---

## 💡 Objetivo Principal da 1ª Sprint

Entregar o **Módulo de Tomada de Decisão (MTD)** funcional e a **estrutura inicial do sistema Flask** conectada ao banco de dados **MySQL**, com dados de exemplo populados e um **dashboard web** simples exibindo as recomendações de venda.

---

## ⚙️ Tecnologias Utilizadas

| Categoria | Tecnologia |
|------------|-------------|
| 💻 Linguagem | Python |
| 🌐 Framework | Flask |
| 🗄️ Banco de Dados | MySQL |
| 📊 Dashboard | HTML, Bootstrap, Chart.js |
| 🔧 Controle de Versão | Git + GitHub |
| 🧩 Gerenciamento de Tarefas | GitHub Projects (Kanban) |

---

## 🧱 Estrutura do Sistema

erp-fazenda-porteira-azul/
│
├── app/
│ ├── app.py # Arquivo principal do Flask
│ ├── models.py # Modelos e tabelas (SQLAlchemy)
│ ├── routes.py # Rotas e endpoints
│ ├── mtd.py # Lógica do módulo de decisão
│ ├── templates/ # HTML do dashboard
│ └── static/ # CSS, JS e gráficos
│
├── init_db.sql # Script de criação e carga do banco MySQL
├── requirements.txt # Dependências do projeto
├── README.md # Este arquivo 
└── .gitignore


## 🧮 Módulo de Tomada de Decisão (MTD)

O **MTD** analisa múltiplas variáveis de mercado e de produção para indicar **quando vender os grãos** (Café, Soja, Milho).

### 🔢 Indicadores Considerados

| Indicador | Descrição | Fórmula |
|------------|------------|----------|
| **Ponto de equilíbrio** | Preço mínimo para cobrir custos | `preço_min = custo_por_saca` |
| **Margem de contribuição** | Lucro desejado sobre o custo | `preço_alvo = custo_por_saca * (1 + margem%)` |
| **Sazonalidade** | Variação de preço histórico | Comparação com média do mesmo período |
| **Recomendação final** | Sugestão de venda ou espera | Avaliação automática com base nos indicadores |

### 🚦 Zonas de Alerta
- 🟥 **Zona Vermelha** → Preço abaixo do custo (prejuízo)  
- 🟨 **Zona Amarela** → Preço entre custo e alvo (analisar)  
- 🟩 **Zona Verde** → Preço acima da margem desejada (vender)

---

## 📊 Dashboard Interativo

O dashboard exibe:
- Gráficos de preços históricos  
- Indicadores financeiros (custo, preço atual, margem)  
- Recomendações automáticas (“Vender”, “Esperar”, “Zona de Interesse”)  
- Alertas visuais baseados no preço de mercado  

---

👩‍💻 Equipe de Desenvolvimento
Nome	Função	Responsabilidades
Laura Evelyn Neves Oliveira	Líder do Projeto	integração com MySQL ,testes, layout do sistema e
 entrega no GSA
Amanda	Desenvolvedora	Banco de dados, dashboard web, Estrutura Flask, MTD.

📅 Planejamento (Sprints)
Sprint	Objetivo Principal	Entregável
1	Estrutura Flask + MTD funcional	Endpoint + Dashboard básico
2	CRUDs (Funcionários, Maquinário, Estoque)	Interfaces e formulários
3	Integração total do ERP + testes	Sistema unificado
4	Refinamento e Apresentação Final	Sistema completo e estável

🧾 Licença
Este projeto é de uso acadêmico e foi desenvolvido como parte da disciplina de Sistemas de Apoio à Decisão do IFSULDEMINAS – Campus Machado.

