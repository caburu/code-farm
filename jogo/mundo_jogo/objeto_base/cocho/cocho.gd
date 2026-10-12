extends ObjetoBase

@export_range(1, 100, 1) var capacidade: int = 10
@export var comida_aceita: Item = preload("res://mundo_jogo/itens/milho.tres")
var quantidade_comida: int = 0
var _interativo: ComportamentoInterativo

func _ready() -> void:
	super._ready()
	add_to_group("CochosGalinhas")
	_interativo = obter_comportamento(ComportamentoInterativo)
	_interativo.interagiu.connect(_ao_abastecer)
	$MensagemTimer.timeout.connect(func(): $Mensagem.hide())
	_atualizar_visual()

func _ao_abastecer() -> void:
	var mensagem = abastecer()
	if not mensagem.is_empty():
		$Mensagem.text = mensagem
		$Mensagem.show()
		$MensagemTimer.start()
	# Permite colocar outra porção sem precisar sair da área.
	_interativo.call_deferred("ativar_interacao", self)

func abastecer() -> String:
	if quantidade_comida >= capacidade:
		return "Cocho cheio!"
	var inventario = Global.inventario
	var pilha = inventario.slots[inventario.indice]
	if pilha.item != comida_aceita or pilha.quantidade <= 0:
		return "Selecione milho na hotbar."
	inventario.remover()
	quantidade_comida += 1
	_atualizar_visual()
	return ""

func tem_comida() -> bool:
	return quantidade_comida > 0

func consumir_porcao() -> bool:
	if not tem_comida():
		return false
	quantidade_comida -= 1
	_atualizar_visual()
	return true

func _atualizar_visual() -> void:
	_interativo.texto_interacao = "[E] Colocar milho (%d/%d)" % [quantidade_comida, capacidade]
	$MilhoNoCocho.visible = quantidade_comida > 0

func obter_estado_alimentacao() -> Dictionary:
	return {"quantidade": quantidade_comida}

func restaurar_estado_alimentacao(dados: Dictionary) -> void:
	quantidade_comida = clampi(dados.get("quantidade", 0), 0, capacidade)
	_atualizar_visual()
