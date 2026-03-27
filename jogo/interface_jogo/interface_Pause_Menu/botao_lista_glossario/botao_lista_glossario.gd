class_name BotaoListaGlossario

extends Button

@export var estilo_normal: StyleBoxTexture
@export var estilo_selecionado: StyleBoxTexture

func _ready():
	desativar_modo_selecionado()

func ativar_modo_selecionado():
	if estilo_selecionado:
		add_theme_stylebox_override("normal", estilo_selecionado)
		disabled = true 

func desativar_modo_selecionado():
	if estilo_normal:
		add_theme_stylebox_override("normal", estilo_normal)
		disabled = false
