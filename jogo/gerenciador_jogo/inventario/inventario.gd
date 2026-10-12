class_name Inventario

extends Resource

@export var quantidade_max: int = 6
@export var slots: Array[PilhaItens] = []
var indice: int = 0

func _init(capacidade: int = 6) -> void:
	quantidade_max = maxi(1, capacidade)

	for i in range(quantidade_max):
		var pilha = PilhaItens.new()
		pilha.item = null
		pilha.quantidade = 0
		slots.append(pilha)

	Global.conectar_sinal(Global,"indice_atualizado",Callable(self, "atualizar_indice"))

func atualizar_indice(_indice: int) -> void:
	indice = _indice

func adicionar_item(item: Item) -> bool:
	var pilha_temp = PilhaItens.new()
	pilha_temp.item = item
	for slot in slots:
		if slot.item != null and slot.pode_empilhar_com(pilha_temp):
			slot.quantidade += 1
			Global.emit_signal("item_modificado", slot)
			return true
	
	for slot in slots:
		if slot.item == null:
			slot.item = item
			slot.quantidade = 1
			Global.emit_signal("item_modificado", slot)
			return true
	
	return false

func tem_itens(nomes: Array[String]) -> bool:
	var nomes_faltando = nomes.duplicate()
	for pilha in slots:
		if pilha.item != null and pilha.item.nome in nomes_faltando:
			nomes_faltando.erase(pilha.item.nome)
	
	return nomes_faltando.is_empty()
	
func remover() -> Item:
	slots[indice].quantidade -= 1
	var item: Item = slots[indice].item
	if slots[indice].quantidade == 0:
		slots[indice].item = null
		
	Global.emit_signal("item_modificado", slots[indice])
	return item
	

func remover_item(item: Item) -> bool:
	for slot in slots:
		if item != null and slot.item == item and slot.quantidade > 0:
			slot.quantidade -= 1
			if slot.quantidade == 0:
				slot.item = null
			Global.emit_signal("item_modificado", slot)
			return true
	return false
	
func verificar_tipo(tipo_permitido: String) -> bool:
	if slots[indice].item == null:
		return false
	
	return tipo_permitido == slots[indice].item.tipo
	
func largar_item() -> Item:
	if slots[indice].item == null:
		return null
	return remover()

func mover_item(indice_origem: int, indice_destino: int) -> void:
	var pilha_origem: PilhaItens = slots[indice_origem]
	var pilha_destino: PilhaItens = slots[indice_destino]

	if pilha_destino.item != null and pilha_destino.pode_empilhar_com(pilha_origem):
		pilha_destino.quantidade += pilha_origem.quantidade
		pilha_origem.item = null
		pilha_origem.quantidade = 0
	else:
		var item_temp: Item = pilha_destino.item
		var qtd_temp: int = pilha_destino.quantidade
		pilha_destino.item = pilha_origem.item
		pilha_destino.quantidade = pilha_origem.quantidade
		pilha_origem.item = item_temp
		pilha_origem.quantidade = qtd_temp

	Global.emit_signal("item_modificado", pilha_origem)
	Global.emit_signal("item_modificado", pilha_destino)

func obter_dados_save() -> Array:
	var dados: Array = []
	for pilha in slots:
		dados.append({"item": pilha.item, "quantidade": pilha.quantidade})
	return dados

func restaurar_dados_save(dados: Array, indice_salvo: int = 0) -> void:
	for i in slots.size():
		slots[i].item = null
		slots[i].quantidade = 0
		if i < dados.size() and dados[i] is Dictionary:
			var item_salvo = dados[i].get("item") as Item
			var quantidade: int = maxi(0, dados[i].get("quantidade", 0))
			if item_salvo != null and quantidade > 0:
				slots[i].item = item_salvo
				slots[i].quantidade = quantidade
	indice = clampi(indice_salvo, 0, slots.size() - 1)
	Global.item_modificado.emit(null)
	
func transferir_para(indice_origem: int,destino: Inventario,indice_destino: int) -> bool:
	if destino == null:
		return false

	if indice_origem < 0 or indice_origem >= slots.size():
		return false

	if indice_destino < 0 or indice_destino >= destino.slots.size():
		return false

	if destino == self and indice_origem == indice_destino:
		return false

	var origem: PilhaItens = slots[indice_origem]
	var chegada: PilhaItens = destino.slots[indice_destino]

	if origem.item == null or origem.quantidade <= 0:
		return false

	if chegada.item != null and chegada.pode_empilhar_com(origem):
		# Junta as pilhas.
		chegada.quantidade += origem.quantidade
		origem.item = null
		origem.quantidade = 0
	else:
		# Move para um espaço vazio ou troca as pilhas.
		var item_anterior: Item = chegada.item
		var quantidade_anterior: int = chegada.quantidade

		chegada.item = origem.item
		chegada.quantidade = origem.quantidade

		origem.item = item_anterior
		origem.quantidade = quantidade_anterior

	# Só atualiza as interfaces depois de concluir a transferência.
	Global.emit_signal("item_modificado", origem)
	Global.emit_signal("item_modificado", chegada)

	return true
