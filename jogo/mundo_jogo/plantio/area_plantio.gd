class_name AreaPlantio
extends Area2D

@onready var _label_plantio: Label = $LabelPlantio
@onready var _label_erro: Label = $LabelErro
@onready var _label_regar: Label = $LabelRegar
@onready var _timer: Timer = $Timer
@onready var _terra_molhada: Sprite2D = $TerraMolhada

var _interacao_em_execucao: bool = false
var _jogador_dentro: bool = false
var _tempo_exibicao: float = 3
enum ESTADO {VAZIO, PLANTIO, PRONTO}
var _estado_atual: ESTADO = ESTADO.VAZIO
var _cena_plantio: PackedScene
var _objeto_plantio: ObjetoPlantio
var _frame_plantio: int
var _para_regar: bool = false
var tween_secagem: Tween

func _ready() -> void:
	_preparar_estado_inicial()

func _preparar_estado_inicial():
	_label_plantio.hide()
	_label_erro.hide()
	_terra_molhada.hide()

@warning_ignore('unused_parameter')
func _process(delta: float) -> void:
	var jogador := get_tree().get_first_node_in_group("Jogador") as Jogador
	if jogador == null or not jogador.pode_interagir():
		return
	if _estado_atual == ESTADO.VAZIO:
		_tentar_plantar()
	elif _estado_atual == ESTADO.PLANTIO:
		_tentar_regar()

func _tentar_plantar() -> void:
	if not _jogador_dentro or _interacao_em_execucao:
		return

	if not Input.is_action_just_pressed("interagir"):
		return

	_interacao_em_execucao = true

	var inventario: Inventario = Global.inventario
	var item: Item = inventario.slots[inventario.indice].item
	var erro := plantar_semente(item, inventario)

	if not erro.is_empty():
		_label_plantio.hide()
		_label_erro.text = erro
		_label_erro.show()
		_timer.start(_tempo_exibicao)
		await _timer.timeout
		_label_erro.hide()

	_interacao_em_execucao = false

func _plantar(item: Item):
	var nome_plantio = item.nome.split("_")
	var caminho = "res://mundo_jogo/plantio/objetos_plantio/%s.tscn" % nome_plantio[1]
	_criar_plantio(caminho)

func _criar_plantio(caminho: String) -> void:
	_cena_plantio = load(caminho)
	_objeto_plantio = _cena_plantio.instantiate()
	_objeto_plantio.regar.connect(_ao_pedir_para_regar)
	_objeto_plantio.terminado.connect(_ao_terminar_de_crescer)
	_objeto_plantio.tree_exited.connect(_ao_coletar)
	_objeto_plantio.global_position = Vector2(0.0, -10.0)
	add_child(_objeto_plantio)
	
func _tentar_regar() -> void:
	if not _para_regar:
		return

	if (
		_jogador_dentro
		and Input.is_action_just_pressed("interagir")
		and not _interacao_em_execucao
	):
		_interacao_em_execucao = true
		molhar_terra(3.0)
		_objeto_plantio._processo_plantio(_frame_plantio)
		_interacao_em_execucao = false
		_para_regar = false
		_label_regar.hide()
	
	
func molhar_terra(tempo_de_secar: float) -> void:
	_terra_molhada.show()
	
	if tween_secagem:
		tween_secagem.kill()
	
	tween_secagem = create_tween()
	tween_secagem.tween_property(_terra_molhada, "modulate:a", 0.00, tempo_de_secar).from(0.75)
	tween_secagem.tween_callback(_terra_molhada.hide)

func _ao_detectar_entrada(corpo: Node2D) -> void:
	if corpo.is_in_group("Jogador") and _estado_atual == ESTADO.VAZIO:
		_label_plantio.show()
		_jogador_dentro = true
	elif corpo.is_in_group("Jogador") and _estado_atual == ESTADO.PLANTIO and _para_regar:
		_label_regar.show()
		_jogador_dentro = true
		
func _ao_detectar_saida(corpo: Node2D) -> void:
	if corpo.is_in_group("Jogador") and _estado_atual == ESTADO.VAZIO:
		_label_plantio.hide()
		_jogador_dentro = false
	elif corpo.is_in_group("Jogador") and _estado_atual == ESTADO.PLANTIO:
		_label_regar.hide()
		_jogador_dentro = false
		
func _ao_pedir_para_regar(frame: int):
	_frame_plantio = frame + 1
	_para_regar = true
	
func _ao_terminar_de_crescer():
	_estado_atual = ESTADO.PRONTO
	
func _ao_coletar() -> void:
	_estado_atual = ESTADO.VAZIO
	_frame_plantio = 0
	_para_regar = false
	_label_regar.hide()

func obter_estado_plantio() -> Dictionary:
	if not is_instance_valid(_objeto_plantio) or _objeto_plantio.foi_colhido():
		return {}
	return {
		"estado": _estado_atual, "frame_rega": _frame_plantio,
		"para_regar": _para_regar, "planta": _objeto_plantio.obter_estado(),
		"umidade": _terra_molhada.modulate.a if _terra_molhada.visible else 0.0
	}

func restaurar_estado_plantio(dados: Dictionary) -> void:
	if is_instance_valid(_objeto_plantio):
		remove_child(_objeto_plantio)
		_objeto_plantio.queue_free()
	_objeto_plantio = null
	_estado_atual = ESTADO.VAZIO
	_para_regar = false
	_interacao_em_execucao = false
	_label_plantio.hide()
	_label_regar.hide()
	if tween_secagem:
		tween_secagem.kill()
	_terra_molhada.hide()
	if dados.is_empty():
		return
	var planta: Dictionary = dados.get("planta", {})
	if planta.is_empty() or not ResourceLoader.exists(planta.get("cena", "")):
		return
	_criar_plantio(planta["cena"])
	_objeto_plantio.restaurar_estado(planta)
	_estado_atual = dados.get("estado", ESTADO.PLANTIO)
	_frame_plantio = dados.get("frame_rega", 0)
	_para_regar = dados.get("para_regar", false)
	var umidade: float = clampf(dados.get("umidade", 0.0), 0.0, 0.75)
	if umidade > 0.0:
		_terra_molhada.show()
		_terra_molhada.modulate.a = umidade
		tween_secagem = create_tween()
		tween_secagem.tween_property(_terra_molhada, "modulate:a", 0.0, 3.0 * umidade / 0.75)
		tween_secagem.tween_callback(_terra_molhada.hide)
# Retorna uma mensagem de erro ou "" quando consegue plantar.
func plantar_semente(item: Item, origem: Inventario) -> String:
	if _estado_atual != ESTADO.VAZIO:
		return "Este espaço já está ocupado."

	if origem == null:
		return "Inventário de sementes não encontrado."

	if item == null or item.tipo != "semente":
		return "Escolha uma semente."

	# Por enquanto, esta é a cultura implementada no projeto.
	if item.nome != "semente_morango":
		return "Esta semente ainda não possui plantio disponível."

	if not origem.remover_item(item):
		return "A semente não está mais disponível."

	_estado_atual = ESTADO.PLANTIO
	_frame_plantio = 0
	_para_regar = false
	_label_plantio.hide()
	_label_regar.hide()

	_plantar(item)
	return ""
	
func regar_por_codigo() -> String:
	if _estado_atual == ESTADO.VAZIO:
		return "Não há planta neste espaço."

	if _estado_atual == ESTADO.PRONTO:
		return "A planta já está pronta para colher."

	if not is_instance_valid(_objeto_plantio):
		return "A planta deste espaço não foi encontrada."

	_para_regar = false
	_label_regar.hide()
	molhar_terra(3.0)

	# Os sinais da planta atualizam o próximo frame e o estado.
	return _objeto_plantio.avancar_por_codigo()


func colher_por_codigo(destino: Inventario) -> String:
	if _estado_atual == ESTADO.VAZIO:
		return "Não há planta neste espaço."

	if _estado_atual != ESTADO.PRONTO:
		return "A planta ainda não está pronta para colher."

	if not is_instance_valid(_objeto_plantio):
		return "A planta deste espaço não foi encontrada."

	var erro := _objeto_plantio.colher_para(destino)

	if not erro.is_empty():
		return erro

	var planta := _objeto_plantio
	_objeto_plantio = null

	# Libera o espaço imediatamente para o próximo comando.
	remove_child(planta)

	if not planta.is_queued_for_deletion():
		planta.queue_free()

	return ""
