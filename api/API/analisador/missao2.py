import ast

from .base import AnalisadorMissao
from roteador import registrar_missao


@registrar_missao(2)
class AnalisadorMissao2(AnalisadorMissao):
    def analisar_semantica(self) -> dict:
        for node in ast.walk(self.tree):
            if not isinstance(node, ast.Call):
                continue

            if not isinstance(node.func, ast.Name):
                continue

            if node.func.id != "print":
                continue

            if len(node.args) != 1 or node.keywords:
                continue

            argumento = node.args[0]

            if not isinstance(argumento, ast.Constant):
                continue

            if not isinstance(argumento.value, str):
                continue

            nome_fazenda = argumento.value.strip()

            if not nome_fazenda:
                continue

            return {
                "status": "sucesso",
                "mensagens": ["Nome da fazenda definido!"],
                "dados": {
                    "nome_fazenda": nome_fazenda
                }
            }

        return {
            "status": "erro_semantico",
            "mensagens": [
                'Use print("Nome da sua fazenda") com um nome não vazio.'
            ],
            "dados": {}
        }