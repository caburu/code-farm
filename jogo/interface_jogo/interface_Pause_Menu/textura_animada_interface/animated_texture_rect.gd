extends TextureRect

class_name AnimatedTextureRect

@export var sprite_frames: SpriteFrames
@export var animacao_inicial: String = ""

signal animacao_finalizada(nome: String)

var _nome_animacao_atual := ""
var _indice_frame := 0
var _tempo_espera := 0.0
var _tempo_passado := 0.0
var _loop := true

func _ready():
	if animacao_inicial != "":
		tocar(animacao_inicial)

func _process(delta):
	if _nome_animacao_atual == "":
		return

	_tempo_passado += delta
	if _tempo_passado >= _tempo_espera:
		_tempo_passado = 0.0
		_indice_frame += 1
		var total_frames = sprite_frames.get_frame_count(_nome_animacao_atual)

		if _indice_frame >= total_frames:
			if _loop:
				_indice_frame = 0
			else:
				var finalizada = _nome_animacao_atual
				_nome_animacao_atual = ""
				emit_signal("animacao_finalizada", finalizada)
				return

		_tempo_espera = sprite_frames.get_frame_duration(_nome_animacao_atual, _indice_frame)
		_atualizar_frame()

func _atualizar_frame():
	if sprite_frames.has_animation(_nome_animacao_atual) and _indice_frame < sprite_frames.get_frame_count(_nome_animacao_atual):
		texture = sprite_frames.get_frame_texture(_nome_animacao_atual, _indice_frame)

func tocar(nome: String, loop := true):
	if not sprite_frames or not sprite_frames.has_animation(nome):
		push_error("Animação '%s' não encontrada." % nome)
		return
	
	_nome_animacao_atual = nome
	_indice_frame = 0
	_loop = loop
	_tempo_espera = sprite_frames.get_frame_duration(nome, 0)
	_tempo_passado = 0.0
	_atualizar_frame()
