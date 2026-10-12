class_name InterfaceBancada
extends Control

signal execucao_solicitada(bancada: Bancada, codigo: String)

@onready var _editor: CodeEdit = %CodeEdit
@onready var _mensagens: Label = %Mensagens
@onready var _botao_limpar: Button = %BotaoLimpar
@onready var _botao_executar: Button = %BotaoVerificar
@onready var _botao_fechar: Button = $Fechar/MarginContainer/BotaoFechar
@onready var _botao_glossario: Button = $BotaoGlossario
@onready var _interface_padrao: Control = $"../InterfacePadrao"
@onready var _painel_bancada: Control = $EditorCodigo/MarginContainer/FundoMenuLateral
@export_range(1.0, 3.0, 0.1) var aproximacao_canteiro: float = 1.8

var _zoom_camera_anterior: Vector2
var _camera_bancada: Camera2D
var _offset_camera_anterior: Vector2
var _tween_camera: Tween

const API_PLANTIO: String = "https://code-farm-x5um.onrender.com/analisar_plantio"

var _http: HTTPRequest
var _pedido_bancada: Bancada
var _consultando: bool = false

var _interface_padrao_estava_visivel: bool = false

var _bancada_atual: Bancada
var _jogador: Jogador


func _ready() -> void:
	hide()

	_botao_limpar.pressed.connect(_ao_limpar)
	_botao_executar.pressed.connect(_ao_executar)
	_botao_fechar.pressed.connect(fechar)
	_editor.text_changed.connect(_ao_alterar_codigo)
	_botao_glossario.pressed.connect(_ao_abrir_glossario)
	get_viewport().size_changed.connect(_atualizar_enquadramento)
	
	_http = HTTPRequest.new()
	_http.timeout = 30.0
	_http.body_size_limit = 1048576
	add_child(_http)
	_http.request_completed.connect(_ao_receber_plantio)


func abrir(bancada: Bancada) -> void:
	if not is_instance_valid(bancada):
		return

	if is_instance_valid(_bancada_atual):
		fechar()

	_interface_padrao_estava_visivel = _interface_padrao.visible
	_interface_padrao.hide()

	_bancada_atual = bancada
	_editor.text = bancada.codigo_digitado
	_editor.editable = true
	_mensagens.text = ""

	_jogador = get_tree().get_first_node_in_group(
		"Jogador"
	) as Jogador

	if is_instance_valid(_jogador):
		_jogador.desativar_movimento()

	show()
	_editor.grab_focus()
	show()
	_editor.grab_focus()
	_iniciar_enquadramento()


func fechar() -> void:
	_restaurar_enquadramento()
	_cancelar_consulta()

	var tinha_bancada_aberta := is_instance_valid(_bancada_atual)

	_ao_alterar_codigo()
	_editor.release_focus()
	hide()

	if tinha_bancada_aberta:
		_bancada_atual.liberar_interacao()
		_interface_padrao.visible = _interface_padrao_estava_visivel

	if is_instance_valid(_jogador):
		_jogador.ativar_movimento()

	_bancada_atual = null
	_jogador = null


func _ao_alterar_codigo() -> void:
	if is_instance_valid(_bancada_atual):
		_bancada_atual.codigo_digitado = _editor.text


func _ao_limpar() -> void:
	_editor.clear()
	_mensagens.text = ""
	_editor.grab_focus()

func _ao_abrir_glossario() -> void:
	_editor.release_focus()
	Global.abrir_glossario.emit()
	
func _ao_executar() -> void:
	if _consultando:
		return

	if not is_instance_valid(_bancada_atual):
		return

	if _editor.text.strip_edges().is_empty():
		_mensagens.text = "Escreva um código antes de executar."
		return

	if not is_instance_valid(_bancada_atual.bau):
		_mensagens.text = "Esta bancada não tem um baú associado."
		return

	if not is_instance_valid(_bancada_atual.registro_plantio):
		_mensagens.text = "Associe o registro de plantio à bancada."
		return

	_ao_alterar_codigo()
	_pedido_bancada = _bancada_atual
	_definir_consulta(true)
	_mensagens.text = "Analisando código..."

	var erro := _http.request(
		API_PLANTIO,
		PackedStringArray(["Content-Type: application/json"]),
		HTTPClient.METHOD_POST,
		JSON.stringify({"codigo": _editor.text})
	)

	if erro != OK:
		_pedido_bancada = null
		_definir_consulta(false)
		_mensagens.text = "Não foi possível iniciar a consulta à API."
		
func _definir_consulta(ativa: bool) -> void:
	_consultando = ativa
	_botao_executar.disabled = ativa
	_botao_limpar.disabled = ativa
	_editor.editable = not ativa


func _cancelar_consulta() -> void:
	if is_instance_valid(_http):
		_http.cancel_request()

	_pedido_bancada = null
	_definir_consulta(false)


func _ao_receber_plantio(
	resultado: int,
	codigo_http: int,
	_headers: PackedStringArray,
	corpo: PackedByteArray
) -> void:
	var bancada := _pedido_bancada
	_pedido_bancada = null
	_definir_consulta(false)

	if not is_instance_valid(bancada):
		return

	if bancada != _bancada_atual:
		return

	if resultado != HTTPRequest.RESULT_SUCCESS:
		_mensagens.text = "Falha de conexão. Confira se a API está rodando."
		return

	if codigo_http != 200:
		_mensagens.text = "A API respondeu com erro HTTP %d." % codigo_http
		return

	var resposta: Variant = JSON.parse_string(corpo.get_string_from_utf8())

	if not resposta is Dictionary:
		_mensagens.text = "A API devolveu uma resposta inválida."
		return

	if resposta.get("status", "") != "sucesso":
		var mensagens: Variant = resposta.get("mensagens", [])
		var textos := PackedStringArray()

		if mensagens is Array:
			for mensagem in mensagens:
				textos.append(str(mensagem))

		_mensagens.text = (
			"\n".join(textos)
			if not textos.is_empty()
			else "Não foi possível analisar o código."
		)
		return

	var dados: Variant = resposta.get("dados", {})

	if not dados is Dictionary:
		_mensagens.text = "A resposta não contém dados válidos."
		return

	var acoes: Variant = dados.get("acoes", [])

	if not acoes is Array:
		_mensagens.text = "A resposta não contém uma lista de ações."
		return

	_mensagens.text = bancada.executar_acoes(acoes)
	
func _iniciar_enquadramento() -> void:
	_camera_bancada = get_viewport().get_camera_2d()

	if not is_instance_valid(_camera_bancada):
		return

	_offset_camera_anterior = _camera_bancada.offset
	_zoom_camera_anterior = _camera_bancada.zoom
	_atualizar_enquadramento()


func _atualizar_enquadramento() -> void:
	# Espera os containers terminarem de posicionar o painel.
	await get_tree().process_frame

	if not is_instance_valid(_camera_bancada):
		return

	if not is_instance_valid(_bancada_atual):
		return

	var registro := _bancada_atual.registro_plantio

	if not is_instance_valid(registro):
		return

	var primeiro := registro.obter_espaco(
		_bancada_atual.id_canteiro, 0, 0
	)

	var ultimo := registro.obter_espaco(
		_bancada_atual.id_canteiro,
		RegistroPlantio.LINHAS - 1,
		RegistroPlantio.COLUNAS - 1
	)

	if not is_instance_valid(primeiro) or not is_instance_valid(ultimo):
		return

	var centro_canteiro: Vector2 = (
		primeiro.global_position + ultimo.global_position
	) / 2.0

	var tamanho_tela: Vector2 = get_viewport_rect().size

	# Posição do início do painel nas coordenadas do viewport.
	var esquerda_painel: float = (
		_painel_bancada.get_global_transform_with_canvas().origin.x
	)
	esquerda_painel = clampf(esquerda_painel, 0.0, tamanho_tela.x)

	# Centro da região que sobra à esquerda do painel.
	var destino_na_tela := Vector2(
		esquerda_painel / 2.0,
		tamanho_tela.y / 2.0
	)

	var zoom_destino: Vector2 = (
		_zoom_camera_anterior * aproximacao_canteiro
	)

	var compensacao: Vector2 = (
		(tamanho_tela / 2.0 - destino_na_tela)
		/ zoom_destino
	)
	var novo_offset: Vector2 = (
		centro_canteiro
		- _camera_bancada.global_position
		+ compensacao
	)

	if _tween_camera != null and _tween_camera.is_valid():
		_tween_camera.kill()

	_tween_camera = create_tween()
	_tween_camera.set_parallel(true)
	_tween_camera.set_trans(Tween.TRANS_SINE)
	_tween_camera.set_ease(Tween.EASE_IN_OUT)

	_tween_camera.tween_property(
		_camera_bancada, "offset", novo_offset, 0.3
	)

	_tween_camera.tween_property(
		_camera_bancada, "zoom", zoom_destino, 0.3
	)


func _restaurar_enquadramento() -> void:
	if _tween_camera != null and _tween_camera.is_valid():
		_tween_camera.kill()

	_tween_camera = null

	if is_instance_valid(_camera_bancada):
		_camera_bancada.offset = _offset_camera_anterior
		_camera_bancada.zoom = _zoom_camera_anterior

	_camera_bancada = null
	
