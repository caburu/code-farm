extends CharacterBody2D

@export var dados_dialogo: DadosDialogo 
@export var nome: String
@export var foto: String
@export var estoque: EstoqueTroca

@onready var area_interacao = $ObjetoInterativo

func _ready() -> void:
	# Cada partida/NPC possui quantidades próprias; os Items continuam compartilhados.
	if estoque:
		estoque = estoque.duplicate()
		estoque.quantidades = estoque.quantidades.duplicate()
	area_interacao.ativar_interacao()
	area_interacao._label_interacao.text = "[E] para Falar" 
	area_interacao.interagiu.connect(_ao_interagir)

func _ao_interagir() -> void:
	Global.emit_signal("iniciar_dialogo_npc", self)
