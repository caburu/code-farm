extends CharacterBody2D

class_name BaseAnimal

enum ESTADO {ANDAR, PARAR}
@export var velocidade_movimento : float = 20
@export var tempo_parado : float = 3
@export var tempo_andando : float = 3

@onready var _animador : AnimationPlayer = $AnimationPlayer
@onready var timer : Timer = $Timer

var _vetor_direcao : Vector2 = Vector2.ZERO
var _direcao_animacao: String = "baixo"
var _estado_atual : ESTADO = ESTADO.PARAR

func _ready():
	timer.timeout.connect(_obter_estado)
	_obter_estado()

func _physics_process(_delta: float) -> void:
	_controle()

func _controle() -> void:
	if (_estado_atual == ESTADO.ANDAR):	
		_movimentar_jogador()
		_obter_direcao_animacao()
	else :
		_vetor_direcao = Vector2.ZERO
	_animar_personagem()
	

func _obter_vetor_direcao():
	_vetor_direcao = Vector2(
		randi_range(-1,1),
		randi_range(-1,1)
	)
	
func _movimentar_jogador() -> void:
	velocity = _vetor_direcao * velocidade_movimento
	move_and_slide()

func _obter_direcao_animacao() -> void:
	# Se houver movimento na horizontal, prioriza essa direção
	if _vetor_direcao.x != 0:
		_direcao_animacao = "esquerda" if _vetor_direcao.x < 0 else "direita"
	# Se não houver movimento horizontal, mas houver na vertical, define a direção vertical
	elif _vetor_direcao.y != 0:
		_direcao_animacao = "cima" if _vetor_direcao.y < 0 else "baixo"

func _animar_personagem() -> void:
	if _vetor_direcao != Vector2.ZERO: 
		_animador.play("andando_" + _direcao_animacao)
	else:
		_animador.play("parado_" + _direcao_animacao)

func _obter_estado():
	if(_estado_atual == ESTADO.PARAR):
		_estado_atual = ESTADO.ANDAR
		_obter_vetor_direcao()
		timer.start(tempo_andando)
	elif(_estado_atual == ESTADO.ANDAR):
		_estado_atual = ESTADO.PARAR
		_obter_vetor_direcao()
		timer.start(tempo_parado)
