class_name Passagem

extends Area2D

signal jogador_passou_passagem(terreno_destino: String, passagem_destino: String)

enum Direcao {
	CIMA,
	BAIXO,
	DIREITA,
	ESQUERDA
}

@export var terreno_destino: String
@export var passagem_destino: String
@export var direcao_spawn: Direcao = Direcao.CIMA

@onready var _posicao_spawn = $PosicaoSpawn

const DISTANCIA_SPAWN = 20

func _ready() -> void:
	add_to_group("Passagens")
	_definir_posicao_spawn()

func _definir_posicao_spawn() -> void:
	match direcao_spawn:
		Direcao.CIMA:
			_posicao_spawn.position.y -= DISTANCIA_SPAWN
		Direcao.BAIXO:
			_posicao_spawn.position.y += DISTANCIA_SPAWN
		Direcao.DIREITA:
			_posicao_spawn.position.x += DISTANCIA_SPAWN
		Direcao.ESQUERDA:
			_posicao_spawn.position.x -= DISTANCIA_SPAWN

func _ao_jogador_passar_passagem(jogador: Node2D) -> void:
	print("DEBUG: Algo encostou na passagem!")
	
	if jogador.is_in_group("Jogador"): 
		print("DEBUG: O objeto É o jogador. Tentando emitir sinal...")
		emit_signal("jogador_passou_passagem", terreno_destino, passagem_destino)
	print("DEBUG: O objeto NÃO está no grupo Jogador. ")

func obter_posicao_spawn():
	return _posicao_spawn.global_position
