class_name SlotHotbar
 
extends MarginContainer
 
signal clicado(slot)
signal drag_iniciado(slot)
 
@onready var _icone := %Icone
@onready var _quantidade := %Quantidade
 
var pilha: PilhaItens
var indice: int = -1
 
func atualizar_slot(nova_pilha: PilhaItens) -> void:
	pilha = nova_pilha
	_icone.texture = pilha.item.icone
	_quantidade.text = str(pilha.quantidade)
 
func limpar_slot() -> void:
	pilha = null
	_icone.texture = null
	_quantidade.text = ""
 
# --- Seleção por clique ---
 
func _gui_input(evento: InputEvent) -> void:
	if evento is InputEventMouseButton:
		if evento.button_index == MOUSE_BUTTON_LEFT and evento.pressed:
			emit_signal("clicado", self)
 
# --- Drag & Drop ---
 
func _get_drag_data(_posicao: Vector2) -> Variant:
	if pilha == null or pilha.item == null:
		return null
 
	# Preview visual que segue o mouse
	var preview = TextureRect.new()
	preview.texture = pilha.item.icone
	preview.custom_minimum_size = Vector2(24, 24)
	preview.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	set_drag_preview(preview)
 
	emit_signal("drag_iniciado", self)
	return { "slot_origem": self }
 
func _can_drop_data(_posicao: Vector2, dados: Variant) -> bool:
	return dados is Dictionary and dados.has("slot_origem")
 
func _drop_data(_posicao: Vector2, dados: Variant) -> void:
	var slot_origem: SlotHotbar = dados["slot_origem"]
	if slot_origem == self:
		return
	emit_signal("clicado", self)
	Global.inventario.mover_item(slot_origem.indice, self.indice)
