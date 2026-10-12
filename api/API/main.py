#Estrutura do projeto
#
# API
# |__ analisador
#     |__ __init__.py
#     |__ base.py
#     |__ missao1.py
#     |__ missao2.py
#     |__ ...
# |__ testes
#     |__ test_missao1.py
#     |__ test_missao2.py
#     |__ ...
# |__ main.py
# |__ modelos.py
# |__ roteador.py

#cd api
#venv\Scripts\activate
#cd API
#uvicorn main:app --reload

#main.py

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from modelos import RequisicaoPlantio
from plantio import analisar_plantio

from modelos import RequisicaoCodigo
from roteador import obter_analisador
import analisador

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/analisar_codigo")
def endpoint_analisar_codigo(requisicao: RequisicaoCodigo):
    try:
        analisador = obter_analisador(requisicao.id_missao, requisicao.codigo, requisicao.contexto)
        return analisador.analisar()
    except ValueError as e:
        return {
            "status": "erro_desconhecido",
            "mensagens": [str(e)],
            "dados": {}
        }

@app.post("/analisar_plantio")
def endpoint_analisar_plantio(requisicao: RequisicaoPlantio):
    return analisar_plantio(requisicao.codigo)