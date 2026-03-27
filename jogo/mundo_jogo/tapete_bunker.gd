extends Node2D

signal jogador_passou_passagem(terreno_destino: String, passagem_destino: String)

@export var terreno_destino: String
@export var passagem_destino: String

func _ready():
	var obj_interativo = $ObjetoInterativo
	obj_interativo.connect("interagiu", Callable(self, "_ao_interagir"))
	add_to_group("Passagens") # importante pro mundo_jogo.gd reconhecer

func _ao_interagir():
	emit_signal("jogador_passou_passagem", terreno_destino, passagem_destino)
