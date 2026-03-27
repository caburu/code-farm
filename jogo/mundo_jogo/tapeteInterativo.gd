extends StaticBody2D
class_name TapeteInterativo

signal jogador_passou_passagem(terreno_destino: String, passagem_destino: String)

@export var terreno_destino: String
@export var passagem_destino: String
@export var direcao_spawn: int = 0
const DISTANCIA_SPAWN = 20

@onready var _animador: AnimationPlayer = $Animador if has_node("Animador") else null
@onready var _sprite: Sprite2D = $Sprite if has_node("Sprite") else null
@onready var _label_interacao: Label = $LabelInteracao if has_node("LabelInteracao") else null
@onready var _colisao: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null
@onready var _posicao_spawn = $PosicaoSpawn if has_node("PosicaoSpawn") else null

var _jogador_dentro: bool = false
var _interecao_em_execucao: bool = false

func _ready() -> void:
	add_to_group("Passagens")
	if _label_interacao:
		_label_interacao.visible = false
		#_label_interacao.text = "Pressione E para usar o tapete"

	# Cria uma área para detectar o jogador, se ainda não houver
	if not has_node("AreaDeteccao"):
		var area = Area2D.new()
		area.name = "AreaDeteccao"
		add_child(area)
		var shape = CollisionShape2D.new()
		shape.shape = RectangleShape2D.new()
		shape.shape.extents = Vector2(32, 16) # ajuste conforme o tamanho do tapete
		area.add_child(shape)
		area.connect("body_entered", Callable(self, "_on_body_entered"))
		area.connect("body_exited", Callable(self, "_on_body_exited"))
	else:
		var area = $AreaDeteccao
		area.connect("body_entered", Callable(self, "_on_body_entered"))
		area.connect("body_exited", Callable(self, "_on_body_exited"))

	add_to_group("Passagens")


func _process(delta: float) -> void:
	if _jogador_dentro and Input.is_action_just_pressed("interagir"):
		_on_interagir()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Jogador"):
		_jogador_dentro = true
		if _label_interacao:
			_label_interacao.visible = true


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Jogador"):
		_jogador_dentro = false
		if _label_interacao:
			_label_interacao.visible = false


func _on_interagir() -> void:
	if _interecao_em_execucao:
		return
	_interecao_em_execucao = true

	if _animador and _animador.has_animation("ativar"):
		_animador.play("ativar")
		await _animador.animation_finished
	else:
		await get_tree().create_timer(0.3).timeout

	emit_signal("jogador_passou_passagem", terreno_destino, passagem_destino)

	_interecao_em_execucao = false


func obter_posicao_spawn() -> Vector2:
	if _posicao_spawn:
		return _posicao_spawn.global_position
	var pos = global_position
	match direcao_spawn:
		0: pos.y -= DISTANCIA_SPAWN
		1: pos.y += DISTANCIA_SPAWN
		2: pos.x += DISTANCIA_SPAWN
		3: pos.x -= DISTANCIA_SPAWN
	return pos
