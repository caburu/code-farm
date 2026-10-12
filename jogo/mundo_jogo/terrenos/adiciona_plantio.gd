class_name RegistroPlantio	
extends Node2D

const CENA_AREA_PLANTIO = preload('res://mundo_jogo/plantio/area_plantio.tscn')
const LINHAS: int = 5
const COLUNAS: int = 2

var _canteiros: Array = []

var posicao_canteiro: Array[Vector2] = [
	Vector2(-114.0, -274.0), Vector2(-93.0, -274.0),
	Vector2(-114.0, -253.0), Vector2(-93.0, -253.0),
	Vector2(-114.0, -232.0), Vector2(-93.0, -232.0),
	Vector2(-114.0, -211.0), Vector2(-93.0, -211.0),
	Vector2(-114.0, -190.0), Vector2(-93.0, -190.0)
]

var distancia_direita_canteiro: Vector2 = Vector2(64.0, 0.0)
var distancia_baixo_canteiro: Vector2 = Vector2(0.0, 128.0)

func _ready() -> void:
	gerar_canteiros()


func gerar_canteiros() -> void:
	#Canteiro 1
	instanciar_grupo(Vector2.ZERO)
	
	#Canteriro 2
	instanciar_grupo(distancia_baixo_canteiro)
	
	#Canteiro 3
	var deslocamento = 2 * distancia_baixo_canteiro
	instanciar_grupo(deslocamento)
	
	#Canteiro 4
	instanciar_grupo(distancia_direita_canteiro)
	
	#Canteiro 5
	deslocamento = distancia_baixo_canteiro + distancia_direita_canteiro
	instanciar_grupo(deslocamento)
	
	#Canteiro 6
	deslocamento = 2 * distancia_baixo_canteiro + distancia_direita_canteiro
	instanciar_grupo(deslocamento)


func instanciar_grupo(deslocamento: Vector2) -> void:
	var matriz: Array = []

	for linha in range(LINHAS):
		var espacos_da_linha: Array[Area2D] = []

		for coluna in range(COLUNAS):
			var indice_posicao := linha * COLUNAS + coluna
			var area := CENA_AREA_PLANTIO.instantiate() as Area2D

			area.position = posicao_canteiro[indice_posicao] + deslocamento
			area.name = "Canteiro_%d_%d" % [
				int(area.position.x),
				int(area.position.y)
			]

			add_child(area)
			espacos_da_linha.append(area)

		matriz.append(espacos_da_linha)

	_canteiros.append(matriz)
func obter_espaco(
	id_canteiro: int,
	linha: int,
	coluna: int
) -> Area2D:
	if id_canteiro < 0 or id_canteiro >= _canteiros.size():
		return null

	if linha < 0 or linha >= LINHAS:
		return null

	if coluna < 0 or coluna >= COLUNAS:
		return null

	return _canteiros[id_canteiro][linha][coluna] as Area2D

	
