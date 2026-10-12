class_name PainelTroca
extends Control

enum ErroTroca {
	ESTOQUE_CHEIO,
	ESTOQUE_ESGOTADO,
	MOEDAS_INSUFICIENTES,
	INVENTARIO_CHEIO,
	ITEM_NAO_COMERCIALIZADO,
	ITEM_INDISPONIVEL
}

signal troca_recusada(motivo: ErroTroca)
signal troca_concluida

@onready var grid_npc: GridContainer = %GridContainerNPC
const CENA_SLOT = preload("res://gerenciador_jogo/gerenciador_npcs/troca/slot_troca.tscn")
@onready var tooltip: CenterContainer = $"../TooltipConfirmacao"

var _estoque_npc_atual: EstoqueTroca

func _ready() -> void:
	tooltip.transacao_confirmada.connect(_processar_transacao)

func abrir(estoque: EstoqueTroca) -> void:
	_estoque_npc_atual = estoque
	tooltip.hide()
	show()
	_preencher_loja(estoque)

func _preencher_loja(estoque: EstoqueTroca) -> void:
	# Lógica de limpar e instanciar slots fica isolada aqui
	for filho in grid_npc.get_children():
		grid_npc.remove_child(filho)
		filho.queue_free()
		
	for item_npc in estoque.itens_a_venda:
		var slot = CENA_SLOT.instantiate()
		grid_npc.add_child(slot)
		slot.configurar(item_npc, estoque.obter_quantidade(item_npc))
		slot.slot_clicado.connect(_ao_clicar_para_comprar)

	# Recebe o arraste também sobre os botões, ícones e fundos da loja.
	for controle: Control in find_children("*", "Control", true, false):
		controle.set_drag_forwarding(Callable(), _can_drop_data, _drop_data)

func _can_drop_data(_posicao: Vector2, dados: Variant) -> bool:
	# Receber a tentativa não significa aprovar a venda.
	return is_visible_in_tree() and not tooltip.visible and _obter_item_arrastado(dados) != null

func _drop_data(posicao: Vector2, dados: Variant) -> void:
	if not _can_drop_data(posicao, dados):
		return
	_ao_clicar_para_vender(_obter_item_arrastado(dados))

func _obter_item_arrastado(dados: Variant) -> Item:
	if not dados is Dictionary or _estoque_npc_atual == null:
		return null
	var slot_origem: SlotHotbar = dados.get("slot_origem") as SlotHotbar
	if not is_instance_valid(slot_origem) or slot_origem.pilha == null:
		return null
	if slot_origem.pilha.item == null or slot_origem.pilha.quantidade <= 0:
		return null
	return slot_origem.pilha.item

func _validar_item(item: Item) -> bool:
	if item == null:
		troca_recusada.emit(ErroTroca.ITEM_INDISPONIVEL)
		return false
	if not _estoque_npc_atual.comercializa(item) or item.preco < 0:
		troca_recusada.emit(ErroTroca.ITEM_NAO_COMERCIALIZADO)
		return false
	return true

func _validar_venda(item: Item) -> bool:
	if not _validar_item(item):
		return false
	if item.preco == 0:
		troca_recusada.emit(ErroTroca.ITEM_NAO_COMERCIALIZADO)
		return false
	if not _estoque_npc_atual.pode_receber(item):
		troca_recusada.emit(ErroTroca.ESTOQUE_CHEIO)
		return false
	return true

func _ao_clicar_para_comprar(dados: Item) -> void:
	if not _validar_item(dados):
		return
	if _estoque_npc_atual.obter_quantidade(dados) <= 0:
		troca_recusada.emit(ErroTroca.ESTOQUE_ESGOTADO)
		return
	tooltip.abrir_tooltip_confirmacao("Comprar", dados)

func _ao_clicar_para_vender(dados: Item) -> void:
	if _validar_venda(dados):
		tooltip.abrir_tooltip_confirmacao("Vender", dados)

func _processar_transacao(acao: String, dados: Item) -> void:
	if not is_visible_in_tree() or _estoque_npc_atual == null:
		return
	if not _validar_item(dados):
		return
	var jogadores = get_tree().get_nodes_in_group("Jogador")
	if jogadores.is_empty():
		push_error("PainelTroca: nenhum jogador encontrado para processar transação.")
		return
	var jogador = jogadores[0]

	if acao == "Comprar":
		if _estoque_npc_atual.obter_quantidade(dados) <= 0:
			troca_recusada.emit(ErroTroca.ESTOQUE_ESGOTADO)
			return
		if jogador.obter_moedas() < dados.preco:
			troca_recusada.emit(ErroTroca.MOEDAS_INSUFICIENTES)
			return
		if not _estoque_npc_atual.retirar(dados):
			troca_recusada.emit(ErroTroca.ESTOQUE_ESGOTADO)
			return
		if not Global.inventario.adicionar_item(dados):
			# Devolve a reserva antes de informar a falha.
			_estoque_npc_atual.adicionar(dados)
			troca_recusada.emit(ErroTroca.INVENTARIO_CHEIO)
			return
		jogador.remover_moedas(dados.preco)
	elif acao == "Vender":
		if not _validar_venda(dados):
			return
		if not Global.inventario.remover_item(dados):
			troca_recusada.emit(ErroTroca.ITEM_INDISPONIVEL)
			return
		_estoque_npc_atual.adicionar(dados)
		jogador.adicionar_moedas(dados.preco)
	else:
		return

	_preencher_loja(_estoque_npc_atual)
	troca_concluida.emit()
