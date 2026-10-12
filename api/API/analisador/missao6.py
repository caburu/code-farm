import ast
from .base import AnalisadorMissao
from roteador import registrar_missao

@registrar_missao(6)
class AnalisadorMissao6(AnalisadorMissao):
    def analisar_semantica(self) -> dict:
        mensagens = []
        sucesso = False
        erro = None

        encontrou_if = False
        usou_elif = False
        usou_else = False
        usou_print = False
        usou_variavel_comida = False
        condicoes_ok = False

        valores_comida = set()
        prints_dados = []

        for node in ast.walk(self.tree):
            # Verifica se existe variável chamada "comida"
            if isinstance(node, ast.Assign):
                for target in node.targets:
                    if isinstance(target, ast.Name) and target.id == "comida":
                        usou_variavel_comida = True
                        if isinstance(node.value, ast.Constant):
                            valores_comida.add(node.value.value)

            # Verifica estruturas condicionais
            if isinstance(node, ast.If):
                encontrou_if = True

                # Verifica se a condição compara com a variável 'comida'
                if isinstance(node.test, ast.Compare):
                    if isinstance(node.test.left, ast.Name) and node.test.left.id == "comida":
                        condicoes_ok = True

                # Verifica elifs e else aninhados
                o = node
                while hasattr(o, 'orelse') and o.orelse:
                    if len(o.orelse) == 1 and isinstance(o.orelse[0], ast.If):
                        usou_elif = True
                        o = o.orelse[0]
                    else:
                        usou_else = True
                        break

            # Verifica se há print()
            if isinstance(node, ast.Expr) and isinstance(node.value, ast.Call):
                call = node.value
                if isinstance(call.func, ast.Name) and call.func.id == "print":
                    usou_print = True
                    if call.args and isinstance(call.args[0], ast.Constant):
                        prints_dados.append(str(call.args[0].value).lower())

        # Verifica se os prints fazem sentido
        prints_ok = (
            any("galinha" in p for p in prints_dados) and
            any("vaca" in p for p in prints_dados) and
            any("porco" in p for p in prints_dados)
        )

        # Avaliação final
        if (encontrou_if and usou_elif and usou_else and usou_print and
            condicoes_ok and usou_variavel_comida and prints_ok):
            mensagens.append("Muito bem! Você usou if, elif, else com a variável 'comida' e alimentou corretamente cada animal com print()!")
            sucesso = True
        else:
            if not usou_variavel_comida:
                mensagens.append("Você precisa usar uma variável chamada 'comida'.")
                erro = "faltou_variavel"
            elif not condicoes_ok:
                mensagens.append("As condições precisam comparar a variável 'comida'.")
                erro = "comparacao_errada"
            elif not encontrou_if:
                mensagens.append("Você precisa usar a estrutura condicional if.")
                erro = "faltou_if"
            elif not usou_elif:
                mensagens.append("Inclua um elif para tratar o segundo caso.")
                erro = "faltou_elif"
            elif not usou_else:
                mensagens.append("Inclua um else para tratar o caso padrão.")
                erro = "faltou_else"
            elif not usou_print:
                mensagens.append("Você precisa usar print() para mostrar qual animal está sendo alimentado.")
                erro = "faltou_print"
            elif not prints_ok:
                mensagens.append("Os textos dos print() devem indicar corretamente galinha, vaca e porco.")
                erro = "print_incorreto"

        return {
            "status": "sucesso" if sucesso else "erro_semantico",
            "mensagens": mensagens,
            "dados": {
                "erro": erro
            }
        }
