extends CenterContainer

@onready var label_acao: Label = $PanelContainer/VBoxContainer/LabelAcao
@onready var label_preco: Label = $PanelContainer/VBoxContainer/LabelPreco
@onready var botao_confirmar: Button = $PanelContainer/VBoxContainer/Confirmar
@onready var botao_cancelar: Button = $PanelContainer/VBoxContainer/Cancelar

signal transacao_confirmada(acao: String, dados_item: Item)

var _dados_pendentes: Item
var _acao_pendente: String

func _ready() -> void:
	botao_confirmar.pressed.connect(_ao_confirmar)
	
	botao_cancelar.pressed.connect(func(): hide())

func abrir_tooltip_confirmacao(acao: String, dados: Item) -> void:
	_dados_pendentes = dados
	_acao_pendente = acao
	
	label_acao.text = acao + " " + dados.nome + "?"
	label_preco.text = "Por: " + str(dados.preco) + " moedas"
	botao_confirmar.text = acao 
	
	show()
	
func _ao_confirmar() -> void:
	transacao_confirmada.emit(_acao_pendente, _dados_pendentes)
	hide()
