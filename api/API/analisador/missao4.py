#missao3.py

import ast
from .base import AnalisadorMissao
from roteador import registrar_missao

@registrar_missao(4)
class AnalisadorMissao4(AnalisadorMissao):
    def analisar_semantica(self) -> dict:
        mensagens = []
        variaveis = set()
        atribuicoes_validas = 0

        # Percorre todos os nós da árvore para encontrar atribuições
        for node in ast.walk(self.tree):
            if isinstance(node, ast.Assign):
                # Processa cada alvo da atribuição
                for target in node.targets:
                    if isinstance(target, ast.Name):
                        variaveis.add(target.id)
                # Verifica se o valor atribuído é uma string literal
                if isinstance(node.value, ast.Constant) and isinstance(node.value.value, str):
                    atribuicoes_validas += 1

        # Define critérios: devem existir pelo menos duas variáveis diferentes e
        # cada uma delas deve ter sido atribuída com um valor literal do tipo string.
        if len(variaveis) >= 2 and atribuicoes_validas >= 2:
            mensagens.append("Excelente! Você definiu múltiplas variáveis (copos) e atribuiu valores a elas.")
            status = "sucesso"
        else:
            mensagens.append("Atenção: você precisa definir pelo menos duas variáveis distintas (copos) com valores entre aspas, representando o conteúdo de cada um.")
            status = "erro_semantico"

        return {
            "status": status,
            "mensagens": mensagens,
            "dados": {
                "variaveis_definidas": list(variaveis),
                "total_atribuicoes": atribuicoes_validas
            }
        }
