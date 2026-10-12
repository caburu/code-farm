extends CharacterBody2D

class_name Robo

signal interagiu

@export_group("Configurações")
@export var velocidade: float = 80.0
@export var distancia_minima: float = 60.0 # Onde ele para de andar
@export var distancia_limite: float = 200.0 # Se o jogador passar disso, o robô desiste

@onready var _label_interacao: Label = $LabelInteracao
@onready var _area_detecao: Area2D = $AreaDetecao

enum Estados { PARADO, SEGUINDO }
var _estado_atual = Estados.PARADO
var _alvo: Node2D = null
var _jogador_na_area: bool = false

func _ready() -> void:
	add_to_group("Robo")
	_label_interacao.hide()
	
	var jogadores = get_tree().get_nodes_in_group("Jogador")
	if jogadores.size() > 0:
		_alvo = jogadores[0]
	
	_area_detecao.body_entered.connect(_on_body_entered)
	_area_detecao.body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if _jogador_na_area and Input.is_action_just_pressed("interagir"):
		_alternar_estado()

func _physics_process(_delta: float) -> void:
	if _estado_atual == Estados.SEGUINDO and _alvo:
		var distancia = global_position.distance_to(_alvo.global_position)

		if distancia < distancia_limite:
			if distancia > distancia_minima:
				var direcao = global_position.direction_to(_alvo.global_position)
				velocity = direcao * velocidade
			else:
				velocity = Vector2.ZERO
		else:
			# O jogador sumiu ou entrou em uma passagem
			velocity = Vector2.ZERO
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

func _atualizar_texto_instrucao() -> void:
	if _estado_atual == Estados.PARADO:
		_label_interacao.text = "[E] Para Seguir"
	else:
		_label_interacao.text = "[E] Para Parar"

func _alternar_estado() -> void:
	if _estado_atual == Estados.PARADO:
		_estado_atual = Estados.SEGUINDO
	else:
		_estado_atual = Estados.PARADO
	
	_atualizar_texto_instrucao()
	interagiu.emit()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jogador"):
		_jogador_na_area = true
		_atualizar_texto_instrucao()
		_label_interacao.show()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jogador"):
		_jogador_na_area = false
		_label_interacao.hide()
		
func atender_chamado(posicao_jogador: Vector2) -> void:

	var direcao_aparecer = Vector2(-40, -10) 
	global_position = posicao_jogador + direcao_aparecer
	
	_estado_atual = Estados.SEGUINDO
	_atualizar_texto_instrucao()
