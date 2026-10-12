extends MarginContainer

@onready var _quantidade: Label = %Quantidade

func _ready() -> void:
	Global.conectar_sinal(Global, "atualizar_moedas", atualizar_slot)
	Global.conectar_sinal(Global, "descoberta_moedas_atualizada", _atualizar_visibilidade)

	# A interface pode ser criada depois de o saldo inicial ou salvo ser emitido.
	if Global.ultima_quantidade_moedas >= 0:
		atualizar_slot(Global.ultima_quantidade_moedas)
	else:
		var jogador = get_tree().get_first_node_in_group("Jogador")
		if jogador != null:
			atualizar_slot(jogador.obter_moedas())
	_atualizar_visibilidade(Global.moedas_descobertas)

func atualizar_slot(quantidade_moedas: int) -> void:
	_quantidade.text = str(quantidade_moedas)

func _atualizar_visibilidade(descobertas: bool) -> void:
	visible = descobertas
