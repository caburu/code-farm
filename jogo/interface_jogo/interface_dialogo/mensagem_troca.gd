class_name MensagemTroca
extends PanelContainer

@onready var _texto: Label = $MarginContainer/Label
@onready var _timer: Timer = $Timer

func _ready() -> void:
	_texto.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_timer.timeout.connect(limpar)
	visibility_changed.connect(_ao_mudar_visibilidade)
	limpar()

func exibir(texto: String) -> void:
	_texto.text = texto
	show()
	_timer.start()

func limpar() -> void:
	_timer.stop()
	_texto.text = ""
	hide()

func _ao_mudar_visibilidade() -> void:
	if not is_visible_in_tree():
		limpar()
