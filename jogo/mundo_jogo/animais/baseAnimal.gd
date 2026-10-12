extends CharacterBody2D

class_name BaseAnimal

enum ESTADO {ANDAR, PARAR}
var velocidade_movimento : float = 20
var tempo_parado : float = 3
var tempo_andando : float = 3
var tempo_fugindo : float = 3

@onready var _animador : AnimationPlayer = $AnimationPlayer
@onready var timer : Timer = $Timer
@onready var timer_som : Timer = $TimerSom
@onready var area_detecao : Area2D = $Area2D
@onready var som_normal : AudioStreamPlayer2D = $SomNormal
@onready var som_fugindo : AudioStreamPlayer2D = $SomFugindo

var _vetor_direcao : Vector2 = Vector2.ZERO
var _direcao_animacao: String = "baixo"
var _estado_atual : ESTADO = ESTADO.PARAR

func _ready():
	timer.timeout.connect(_obter_estado)
	timer_som.timeout.connect(_tocar_som)
	area_detecao.body_entered.connect(_reagir_ao_personagem)
	_obter_estado()
	_tocar_som()

func _physics_process(_delta: float) -> void:
	_controle()

func _controle() -> void:
	if (_estado_atual == ESTADO.ANDAR):	
		_movimentar_jogador()
		_obter_direcao_animacao()
	else:
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
	
	# tratando colisoes com o cenario
	if get_slide_collision_count() > 0:
		_vetor_direcao = -_vetor_direcao
		# modifica tambem a animacao
		_obter_direcao_animacao()
		_animar_personagem()
		
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
	velocidade_movimento = 20
	if(_estado_atual == ESTADO.PARAR):
		_estado_atual = ESTADO.ANDAR
		_obter_vetor_direcao()
		timer.start(tempo_andando)
	elif(_estado_atual == ESTADO.ANDAR):
		_estado_atual = ESTADO.PARAR
		_obter_vetor_direcao()
		timer.start(tempo_parado)

func _reagir_ao_personagem(body : Node2D):
	if randi() % 100 < 10 and !som_normal.playing and !som_fugindo.playing:
		som_fugindo.play()
	velocidade_movimento = 96
	_estado_atual = ESTADO.ANDAR
	_vetor_direcao = (global_position - body.global_position).normalized()
	timer.stop()
	timer.start(tempo_fugindo)
	
func _tocar_som():
	var tempo = 5 + (randi() % 16)
	if !som_fugindo.playing:
		som_normal.play()
	timer_som.start(tempo)
