import ast


def analisar_plantio(codigo: str) -> dict:
    def erro(mensagem: str, status: str = "erro_semantico") -> dict:
        return {
            "status": status,
            "mensagens": [mensagem],
            "dados": {},
        }

    if len(codigo) > 10_000:
        return erro("O código ultrapassou o limite de tamanho.")

    try:
        arvore = ast.parse(codigo)
    except SyntaxError as exc:
        return erro(
            f"Linha {exc.lineno}, coluna {exc.offset}: {exc.msg}",
            "erro_sintatico",
        )
    except (ValueError, RecursionError):
        return erro("Não foi possível analisar esse código.")

    if not arvore.body:
        return erro("Escreva um comando plantar(), regar() ou colher().")

    if len(arvore.body) > 100:
        return erro("Use no máximo 100 comandos por execução.")

    acoes = []

    for instrucao in arvore.body:
        numero = instrucao.lineno

        if not (
            isinstance(instrucao, ast.Expr)
            and isinstance(instrucao.value, ast.Call)
        ):
            return erro(
                f"Linha {numero}: use plantar(), regar() ou colher()."
            )

        chamada = instrucao.value

        if not isinstance(chamada.func, ast.Name):
            return erro(f"Linha {numero}: chamada de função inválida.")

        nome = chamada.func.id

        if nome not in ("plantar", "regar", "colher"):
            return erro(f"Linha {numero}: função '{nome}' desconhecida.")

        quantidade = 3 if nome == "plantar" else 2

        if len(chamada.args) != quantidade or chamada.keywords:
            assinatura = (
                'plantar("morango", linha, coluna)'
                if nome == "plantar"
                else f"{nome}(linha, coluna)"
            )
            return erro(f"Linha {numero}: use {assinatura}.")

        if not all(isinstance(arg, ast.Constant) for arg in chamada.args):
            return erro(
                f"Linha {numero}: use valores diretos nos argumentos."
            )

        valores = [arg.value for arg in chamada.args]

        if nome == "plantar":
            cultura, linha, coluna = valores

            if type(cultura) is not str or cultura != "morango":
                return erro(
                    f'Linha {numero}: a cultura disponível é "morango".'
                )
        else:
            linha, coluna = valores

        if type(linha) is not int or type(coluna) is not int:
            return erro(
                f"Linha {numero}: linha e coluna devem ser inteiros."
            )

        if not (0 <= linha < 5 and 0 <= coluna < 2):
            return erro(
                f"Linha {numero}: use linhas de 0 a 4 e colunas de 0 a 1."
            )

        acao = {
            "tipo": nome,
            "linha": linha,
            "coluna": coluna,
            "linha_codigo": numero,
        }

        if nome == "plantar":
            acao["cultura"] = cultura

        acoes.append(acao)

    return {
        "status": "sucesso",
        "mensagens": [],
        "dados": {"acoes": acoes},
    }