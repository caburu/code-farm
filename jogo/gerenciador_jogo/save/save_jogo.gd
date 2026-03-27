class_name SaveJogo
extends Resource

# Adicionamos o nome da fazenda e a data 
@export var nome_fazenda: String = "Nova Fazenda"
@export var data_hora: Dictionary = {} 

@export var missao_atual: int = 1
@export var player_posicao: Vector2 = Vector2.ZERO
@export var inventario_dados: Array = [] # Futuramente para o inventário
