class_name InterfaceBau
extends Control

@onready var _grid: GridContainer = %GridContainer
@onready var _botao_fechar: Button = $BotaoFechar
@onready var _grid_jogador: GridContainer = $GridJogador/MarginContainer/MarginContainer/GridContainer

var _bau_atual: Bau
var _jogador: Jogador


func _ready() -> void:
	hide()

	Global.conectar_sinal(
		Global,
		"item_modificado",
		Callable(self, "_ao_modificar_item")
	)


func abrir(bau: Bau) -> void:
	if not is_instance_valid(bau):
		return

	if visible:
		fechar()

	_bau_atual = bau

	_jogador = get_tree().get_first_node_in_group("Jogador") as Jogador

	if is_instance_valid(_jogador):
		_jogador.desativar_movimento()

	atualizar_slots()
	show()


func fechar() -> void:
	hide()

	if is_instance_valid(_bau_atual):
		var interacao = _bau_atual.obter_comportamento(ComportamentoInterativo) as ComportamentoInterativo

		if interacao != null:
			interacao.liberar_interacao()

	if is_instance_valid(_jogador):
		_jogador.ativar_movimento()

	_bau_atual = null
	_jogador = null

	atualizar_slots()


func atualizar_slots() -> void:
	var inventario_do_bau: Inventario = null
	var inventario_do_jogador: Inventario = null

	if is_instance_valid(_bau_atual):
		inventario_do_bau = _bau_atual.inventario_bau
		inventario_do_jogador = Global.inventario

	_preencher_grade(_grid, inventario_do_bau)
	_preencher_grade(_grid_jogador, inventario_do_jogador)


func _preencher_grade(grade: GridContainer,inventario: Inventario) -> void:
	for i in range(grade.get_child_count()):
		var slot = grade.get_child(i) as SlotHotbar

		if slot == null:
			continue

		slot.limpar_slot()

		# Cada espaço recebe o inventário e o índice que representa.
		slot.set_drag_forwarding(
			_iniciar_arraste.bind(slot, inventario, i),
			_pode_receber_arraste.bind(inventario, i),
			_receber_arraste.bind(inventario, i)
		)

		if inventario == null or i >= inventario.slots.size():
			continue

		var pilha: PilhaItens = inventario.slots[i]

		if pilha.item != null and pilha.quantidade > 0:
			slot.atualizar_slot(pilha)


func _ao_modificar_item(_pilha: PilhaItens) -> void:
	if visible:
		atualizar_slots()
		
func _iniciar_arraste(_posicao: Vector2,slot: SlotHotbar,inventario: Inventario,indice: int) -> Variant:
	if not is_visible_in_tree() or inventario == null:
		return null

	if indice < 0 or indice >= inventario.slots.size():
		return null

	var pilha: PilhaItens = inventario.slots[indice]

	if pilha.item == null or pilha.quantidade <= 0:
		return null

	var preview = TextureRect.new()
	preview.texture = pilha.item.icone
	preview.custom_minimum_size = Vector2(24, 24)
	preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	slot.set_drag_preview(preview)

	return {
		"tipo": "transferencia_bau",
		"inventario": inventario,
		"indice": indice,
		"item": pilha.item
	}


func _pode_receber_arraste(_posicao: Vector2,dados: Variant,destino: Inventario,indice_destino: int) -> bool:
	if not is_visible_in_tree() or not is_instance_valid(_bau_atual):
		return false

	if not dados is Dictionary:
		return false

	if dados.get("tipo") != "transferencia_bau":
		return false

	var origem = dados.get("inventario") as Inventario
	var indice_origem: int = dados.get("indice", -1)

	if origem == null or destino == null:
		return false

	# Aceita somente os inventários desta janela.
	var permitidos = [Global.inventario, _bau_atual.inventario_bau]

	if origem not in permitidos or destino not in permitidos:
		return false

	if indice_origem < 0 or indice_origem >= origem.slots.size():
		return false

	if indice_destino < 0 or indice_destino >= destino.slots.size():
		return false

	if origem == destino and indice_origem == indice_destino:
		return false

	var pilha: PilhaItens = origem.slots[indice_origem]

	return (
		pilha.item != null
		and pilha.quantidade > 0
		and pilha.item == dados.get("item")
	)


func _receber_arraste(posicao: Vector2,dados: Variant,destino: Inventario,indice_destino: int) -> void:
	if not _pode_receber_arraste(
		posicao, dados, destino, indice_destino
	):
		return

	var origem = dados.get("inventario") as Inventario
	var indice_origem: int = dados.get("indice", -1)

	origem.transferir_para(
		indice_origem,
		destino,
		indice_destino
	)
