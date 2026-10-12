class_name Hotbar

extends Control

@onready var _seletor: NinePatchRect = %Seletor
@onready var _grid: GridContainer = %GridContainer

var _slots: Array = []
var _indice_selecionado: int = 0 

func _ready():
	call_deferred("_atualizar_hotbar")
	Global.conectar_sinal(Global, "item_modificado", Callable(self, "_ao_adicionar_item"))
	
func _atualizar_hotbar():	
	while not is_visible_in_tree():
		await get_tree().process_frame
	
	_slots = _grid.get_children()
	
	# Conecta os sinais de cada slot e registra o índice deles
	for i in range(_slots.size()):
		_slots[i].indice = i
		Global.conectar_sinal(_slots[i], "clicado", Callable(self, "_ao_clicar_slot"))
		Global.conectar_sinal(_slots[i], "drag_iniciado", Callable(self, "_ao_iniciar_drag"))

	
	atualizar_slots_com_dados_do_inventario()
	_atualizar_seletor()

func _process(_delta) -> void:
	for i in range(6):
		if Input.is_action_just_pressed("hotbar_" + str(i + 1)):
			_selecionar_slot(i)

func _selecionar_slot(indice: int) -> void:
	if indice >= 0 and indice < _slots.size():
		_indice_selecionado = indice
		Global.emit_signal(&"indice_atualizado", _indice_selecionado)
		_atualizar_seletor()

func _atualizar_seletor() -> void:
	if _slots.is_empty():
		return
	var slot = _slots[_indice_selecionado]
	
	_seletor.global_position = slot.global_position
	_seletor.size = slot.size

func atualizar_slots_com_dados_do_inventario() -> void:
	_indice_selecionado = Global.inventario.indice
	_atualizar_seletor()
	for i in range(_slots.size()):
		var slot = _slots[i]
		
		if Global.inventario.slots[i].item != null:
			slot.atualizar_slot(Global.inventario.slots[i])
		else:
			slot.limpar_slot()

func _ao_mudar_visibilidade_interface_padrao() -> void:
	call_deferred("_atualizar_hotbar")

func _ao_adicionar_item(_pilha: PilhaItens):
	atualizar_slots_com_dados_do_inventario()

func _ao_clicar_slot(slot: SlotHotbar) -> void:
	_selecionar_slot(slot.indice)

func _ao_iniciar_drag(_slot: SlotHotbar) -> void:
	_selecionar_slot(_slot.indice)

func _can_drop_data(_posicao: Vector2, dados: Variant) -> bool:
	return dados is Dictionary and dados.has("slot_origem")

func _drop_data(_posicao: Vector2, dados: Variant) -> void:

	var slot_origem: SlotHotbar = dados["slot_origem"]
	_selecionar_slot(slot_origem.indice)

	var jogadores = get_tree().get_nodes_in_group("Jogador")
	if jogadores.size() > 0:
		jogadores[0].largar_item_no_mundo()
