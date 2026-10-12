extends Node

@onready var _jogador: Jogador = get_parent() as Jogador

var _selecionado: ObjetoBase


func _process(_delta: float) -> void:
	_atualizar_selecao()


func _atualizar_selecao() -> void:
	if not is_instance_valid(_jogador):
		_definir_selecao(null)
		return

	if not _jogador.pode_interagir():
		_definir_selecao(null)
		return

	var mais_proximo: ObjetoBase = null
	var menor_distancia: float = INF

	for candidato in get_tree().get_nodes_in_group("ObjetosInterativos"):
		var objeto = candidato as ObjetoBase

		if objeto == null or objeto.is_queued_for_deletion():
			continue

		var comportamento = objeto.obter_comportamento(
			ComportamentoInterativo
		) as ComportamentoInterativo

		if comportamento == null or not comportamento.pode_interagir():
			continue

		var distancia = _jogador.global_position.distance_squared_to(
			objeto.global_position
		)

		# Em um empate, mantém o objeto que já estava selecionado.
		if (
			distancia < menor_distancia
			or (
				is_equal_approx(distancia, menor_distancia)
				and objeto == _selecionado
			)
		):
			mais_proximo = objeto
			menor_distancia = distancia

	_definir_selecao(mais_proximo)


func _definir_selecao(novo: ObjetoBase) -> void:
	if is_instance_valid(_selecionado):
		if _selecionado == novo:
			return

		var anterior = _selecionado.obter_comportamento(
			ComportamentoInterativo
		) as ComportamentoInterativo

		if anterior != null:
			anterior.definir_selecionado(false)

	_selecionado = novo

	if is_instance_valid(_selecionado):
		var atual = _selecionado.obter_comportamento(
			ComportamentoInterativo
		) as ComportamentoInterativo

		if atual != null:
			atual.definir_selecionado(true)


func _unhandled_input(evento: InputEvent) -> void:
	if not evento.is_action_pressed("interagir") or evento.is_echo():
		return

	# Confere novamente o alvo no momento do pressionamento.
	_atualizar_selecao()

	if not is_instance_valid(_selecionado):
		return

	var comportamento = _selecionado.obter_comportamento(
		ComportamentoInterativo
	) as ComportamentoInterativo

	if comportamento == null:
		return

	get_viewport().set_input_as_handled()

	_definir_selecao(null)
	comportamento.executar_interacao()
