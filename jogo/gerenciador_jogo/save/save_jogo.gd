class_name SaveJogo
extends Resource

# Adicionamos o nome da fazenda e a data 
@export var nome_fazenda: String = "Nova Fazenda"
@export var nome_jogador: String
@export var data_hora: Dictionary = {} 

@export var missao_atual: int = 1
@export var player_posicao: Vector2 = Vector2.ZERO
@export var quantidade_moedas: int = 0
@export var moedas_descobertas: bool = false
@export var inventario_dados: Array = []
@export var versao_save: int = 0
@export var indice_hotbar: int = 0
@export var terreno_player: String = "TerrenoFazenda"
@export var direcao_player: String = "baixo"
@export var mundo_dados: Dictionary = {}
@export var progresso_missoes: Dictionary = {}
