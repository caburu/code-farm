class_name ObjetoPlantio
extends StaticBody2D

@onready var _animador: AnimatedSprite2D = $Fases_Plantio
@onready var _timer: Timer = $Timer
@export var item: Item
var _objeto_coletavel: PackedScene

signal regar(frame: int)
signal terminado

var _frames: int
var _frame_atual: int = 0
const _tempo_crescimento: float = 3
var _produto: Node2D

func _ready() -> void:
	add_to_group("ObjetosPlantio")
	var caminho = "res://mundo_jogo/objeto_coletavel/objetos/%s.tscn" % item.nome
	_objeto_coletavel = load(caminho)
	_frames = _animador.sprite_frames.get_frame_count("fases")
	_timer.one_shot = true
	_timer.timeout.connect(_ao_crescer)
	_processo_plantio(_frame_atual)

func _processo_plantio(
	frame: int,
	imediato: bool = false
) -> void:
	_timer.stop()
	_frame_atual = frame

	if _frame_atual < _frames:
		if imediato:
			_ao_crescer()
		else:
			_timer.start(_tempo_crescimento)
	else:
		terminado.emit()
		_processo_coletar()

func _ao_crescer() -> void:
	_animador.frame = _frame_atual
	_animador.show()
	regar.emit(_frame_atual)

func _processo_coletar() -> void:
	_animador.hide()
	if is_instance_valid(_produto):
		return
	_produto = _objeto_coletavel.instantiate()
	_produto.position = Vector2.ZERO
	_produto.tree_exited.connect(_terminar)
	add_child(_produto)

func _terminar() -> void:
	queue_free()

func foi_colhido() -> bool:
	return is_queued_for_deletion() or (is_instance_valid(_produto) and _produto._interacao_em_execucao)

func obter_estado() -> Dictionary:
	return {
		"cena": scene_file_path, "frame": _frame_atual,
		"frame_visual": _animador.frame, "tempo": _timer.time_left,
		"crescendo": not _timer.is_stopped(), "pronto": _frame_atual >= _frames
	}

func restaurar_estado(dados: Dictionary) -> void:
	_timer.stop()
	_frame_atual = dados.get("frame", 0)
	_animador.frame = dados.get("frame_visual", 0)
	if dados.get("pronto", false):
		terminado.emit()
		_processo_coletar()
	else:
		_animador.show()
		if dados.get("crescendo", false):
			_timer.start(maxf(0.01, dados.get("tempo", _tempo_crescimento)))
			
func avancar_por_codigo() -> String:
	if _frame_atual >= _frames:
		return "A planta já está pronta para colher."

	_processo_plantio(_frame_atual + 1, true)
	return ""


func colher_para(destino: Inventario) -> String:
	if _frame_atual < _frames:
		return "A planta ainda não está pronta para colher."

	var produto := _produto as ObjetoColetavel

	if not is_instance_valid(produto):
		return "Não há produto disponível para colher."

	return produto.guardar_em(destino)
