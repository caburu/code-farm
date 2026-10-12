class_name ObjetoColetavel

extends StaticBody2D

@onready var _animador: AnimationPlayer = $Animador
@onready var _sprite: Sprite2D = $Sprite
@onready var _label_interacao: Label = $LabelInteracao

@export var item: Item

var _jogador_dentro: bool = false
var _interacao_em_execucao: bool = false

func _ready() -> void:
	add_to_group("ObjetosColetaveis")
	_preparar_estado_inicial()
	_label_interacao.hide()

func _preparar_estado_inicial():
	_label_interacao.hide()
	_label_interacao.global_position.y -= _sprite.region_rect.size.y + 16

func _process(delta: float) -> void:
	_se_houver_interacao()

func _se_houver_interacao() -> void:
	if not _jogador_dentro or _interacao_em_execucao:
		return

	var jogador := get_tree().get_first_node_in_group("Jogador") as Jogador

	if jogador == null or not jogador.pode_interagir():
		return

	if not Input.is_action_just_pressed("coletar_item"):
		return

	var erro := guardar_em(Global.inventario)

	if not erro.is_empty():
		print(erro)
		return

	_animador.play("coletar")
	await _animador.animation_finished
	queue_free()

func _ao_detectar_entrada(corpo: Node2D) -> void:
	if corpo.is_in_group("Jogador"):
		_label_interacao.show()
		_jogador_dentro = true
		_animador.play("destacar_objeto")

func _ao_detectar_saida(corpo: Node2D) -> void:
	if corpo.is_in_group("Jogador"):
		_label_interacao.hide()
		_jogador_dentro = false
		_animador.play("RESET")
		
func guardar_em(destino: Inventario) -> String:
	if _interacao_em_execucao:
		return "Este produto já está sendo coletado."

	if destino == null:
		return "Inventário de destino não encontrado."

	if item == null:
		return "O produto não possui um item configurado."

	_interacao_em_execucao = true

	if not destino.adicionar_item(item):
		_interacao_em_execucao = false
		return "O inventário de destino está cheio."

	_label_interacao.hide()
	return ""
