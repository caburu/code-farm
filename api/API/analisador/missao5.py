#missao4.py

import ast
from .base import AnalisadorMissao
from roteador import registrar_missao

@registrar_missao(5)
class AnalisadorMissao5(AnalisadorMissao):
    def analisar_semantica(self) -> dict:
        mensagens = []
        sucesso = False
        encontrou_for = False
        print_ok = False
        quantidade_regas = 0
        erro = None

        for node in ast.walk(self.tree):
            if isinstance(node, ast.For):
                encontrou_for = True
                iterador = node.iter
                iteracoes = 0

                # Verifica se é um range() com argumentos constantes
                if isinstance(iterador, ast.Call) and isinstance(iterador.func, ast.Name) and iterador.func.id == "range":
                    args = iterador.args
                    if all(isinstance(arg, (ast.Constant, ast.Num)) for arg in args):
                        if len(args) == 1:
                            stop = args[0].value
                            start = 0
                            step = 1
                        elif len(args) == 2:
                            start = args[0].value
                            stop = args[1].value
                            step = 1
                        elif len(args) == 3:
                            start = args[0].value
                            stop = args[1].value
                            step = args[2].value
                        else:
                            start = stop = step = None

                        if start is not None and stop is not None and step != 0:
                            iteracoes = max(0, (stop - start + (step - 1 if step > 0 else step + 1)) // step)
                            quantidade_regas = iteracoes

                # Verifica se há print() dentro do for
                for subnode in ast.walk(node):
                    if isinstance(subnode, ast.Expr) and isinstance(subnode.value, ast.Call):
                        call = subnode.value
                        if isinstance(call.func, ast.Name) and call.func.id == "print":
                            print_ok = True

        # Avaliação final
        if encontrou_for and quantidade_regas == 5 and print_ok:
            mensagens.append("Você usou corretamente o for com range que resulta em 5 repetições e exibiu as regas com print()!")
            sucesso = True
        else:
            if not encontrou_for:
                mensagens.append("Você precisa usar um laço for para repetir a ação.")
                erro = "faltou_for"
            elif not print_ok:
                mensagens.append("Use print() dentro do for para mostrar quais alfaces estão sendo regadas.")
                erro = "faltou_print"
            elif quantidade_regas != 5:
                mensagens.append("Use um range que gere exatamente 5 repetições para regar as 5 alfaces.")
                # erro = None neste caso, mas o `quantidade_regas` já será analisado pelo jogo

        return {
            "status": "sucesso" if sucesso else "erro_semantico",
            "mensagens": mensagens,
            "dados": {
                "quantidade_regas": quantidade_regas,
                "erro": erro  # pode ser None, "faltou_for" ou "faltou_print"
            }
        }
