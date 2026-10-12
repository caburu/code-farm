class_name ComportamentoObjeto
extends Resource

## Interface base para comportamentos em ObjetoBase.
## Cada comportamento concreto sobrescreve apenas os métodos que usa.

## Nome do grupo que o objeto deve entrar ao ter este comportamento
## (ex: "ObjetosInterativos"). Deixe vazio se não precisar de grupo.
func nome_grupo() -> String:
	return ""

## Chamado uma vez em ObjetoBase._ready(), após o comportamento ser
## duplicado (cada instância de objeto tem sua própria cópia do Resource).
func inicializar(_objeto: ObjetoBase) -> void:
	pass

## Chamado a cada frame a partir de ObjetoBase._process().
func processar(_objeto: ObjetoBase, _delta: float) -> void:
	pass

## Repassado do sinal body_entered da AreaDetecao do ObjetoBase.
func ao_detectar_entrada(_objeto: ObjetoBase, _corpo: Node2D) -> void:
	pass

## Repassado do sinal body_exited da AreaDetecao do ObjetoBase.
func ao_detectar_saida(_objeto: ObjetoBase, _corpo: Node2D) -> void:
	pass
