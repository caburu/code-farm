class_name InterfaceGlossario
extends Control

@onready var CenaBotaoListaGlossario: PackedScene = preload("res://interface_jogo/interface_Pause_Menu/botao_lista_glossario/botao_lista_glossario.tscn")

@onready var _lista_termos: VBoxContainer = %ListaTermos
@onready var _livro_animado: AnimatedTextureRect = %LivroAnimado
@onready var _pagina_descricao_livro: RichTextLabel = %DescricaoComando
@onready var _pagina_exemplo_livro: RichTextLabel = %ExemploComando
@onready var _titulo_glossario: Label = %TituloGlossario 

var _mapa_botoes_termos: Dictionary = {}
var _indice_termo_atual: int = 0
var _termos_apreendidos: Array = [] # Vai guardar Comandos ou Missões, dependendo da aba!

var _secoes_disponiveis: Array = [
	"Glossário de Comandos Apreendidos",
	"Glossário de Missões"
]
var _indice_secao_atual: int = 0

func _ready():
	_aplicar_corte_em_todos_os_frames()
	_limpar_texto_livro()
	Global.emit_signal("glossario_fechado")
	
	if _titulo_glossario != null:
		_titulo_glossario.text = _secoes_disponiveis[0]

func _aplicar_corte_em_todos_os_frames():
	var frames = _livro_animado.sprite_frames
	if frames == null:
		return
	
	for anim_name in frames.get_animation_names():
		var frame_count = frames.get_frame_count(anim_name)
		for i in range(frame_count):
			var frame_texture = frames.get_frame_texture(anim_name, i)
			var frame_duration = frames.get_frame_duration(anim_name, i)

			if frame_texture is Texture2D:
				var atlas = AtlasTexture.new()
				atlas.atlas = frame_texture
				atlas.region = Rect2(Vector2.ZERO, frame_texture.get_size() - Vector2(9, 0))
				frames.set_frame(anim_name, i, atlas, frame_duration)

func _limpar_texto_livro():
	_pagina_descricao_livro.text = ""
	_pagina_exemplo_livro.text = ""

func _atualizar_lista_termos(filtro: String = ""):
	for chave in _mapa_botoes_termos.keys():
		var botao = _mapa_botoes_termos[chave]
		if filtro == "" or chave.to_lower().contains(filtro.to_lower()):
			botao.show()
		else:
			botao.hide()

	_termos_apreendidos.clear()
	
	var lista_completa = []
	if _indice_secao_atual == 0:
		lista_completa = Global.glossario.obter_lista_termos_aprendidos()
	elif _indice_secao_atual == 1:
		lista_completa = Global.glossario.obter_lista_missoes()
		
	for item in lista_completa:
		if filtro == "" or item.to_lower().contains(filtro.to_lower()):
			_termos_apreendidos.append(item)

func _destacar_botao_termo(chave: String):
	for t in _mapa_botoes_termos.keys():
		var botao = _mapa_botoes_termos[t] as BotaoListaGlossario
		botao.desativar_modo_selecionado()

	if _mapa_botoes_termos.has(chave):
		var botao = _mapa_botoes_termos[chave] as BotaoListaGlossario
		botao.ativar_modo_selecionado()

# --- [ATUALIZADO] Agora acha o índice direto na lista em exibição ---
func _ao_clicar_termo(chave_item: String):
	var indice_destino = _termos_apreendidos.find(chave_item)
	await _folhear_paginas_para(indice_destino)
	_indice_termo_atual = indice_destino
	_destacar_botao_termo(chave_item)
	await _exibir_termo_no_livro(chave_item)

func _folhear_paginas_para(indice_destino: int) -> void:
	var diferenca = indice_destino - _indice_termo_atual
	if diferenca == 0:
		return
	
	var passos = abs(diferenca)
	var voltando = diferenca < 0
	_livro_animado.flip_h = voltando
	
	for i in passos:
		_limpar_texto_livro()
		_livro_animado.tocar("passar_pagina", false)
		await _livro_animado.animacao_finalizada
	
	_livro_animado.flip_h = false

func _exibir_termo_no_livro(chave_item: String) -> void:
	var dados = {}
	
	if _indice_secao_atual == 0:
		dados = Global.glossario.obter_dados_termo(chave_item)
	elif _indice_secao_atual == 1:
		dados = Global.glossario.obter_dados_missao(chave_item)
		
	_limpar_texto_livro()
	
	if not dados.is_empty():
		_pagina_descricao_livro.text = dados["nome"] + ":\n\n" + dados["descricao"]
		_pagina_exemplo_livro.text = dados["tipo"] + "\n\n" + dados["exemplo"]

func _ao_mudar_texto_campo_pesquisa(novo_texto: String) -> void:
	_atualizar_lista_termos(novo_texto)

func _exibir_termo_atual() -> void:
	if _indice_termo_atual >= 0 and _indice_termo_atual < _termos_apreendidos.size():
		var chave_item = _termos_apreendidos[_indice_termo_atual]
		_destacar_botao_termo(chave_item)
		await _exibir_termo_no_livro(chave_item)

func _ao_clicar_voltar_pagina() -> void:
	if _indice_termo_atual > 0:
		var novo_indice = _indice_termo_atual - 1
		await _folhear_paginas_para(novo_indice)
		_indice_termo_atual = novo_indice
		await _exibir_termo_atual()

func _ao_clicar_passar_pagina() -> void:
	if _indice_termo_atual < _termos_apreendidos.size() - 1:
		var novo_indice = _indice_termo_atual + 1
		await _folhear_paginas_para(novo_indice)
		_indice_termo_atual = novo_indice
		await _exibir_termo_atual()

func _inicializar_glossario():
	for botao in _lista_termos.get_children():
		botao.queue_free()
	
	_mapa_botoes_termos.clear()

	for termo in Global.glossario.obter_lista_termos_aprendidos():
		var dados = Global.glossario.obter_dados_termo(termo)

		var botao = CenaBotaoListaGlossario.instantiate()
		botao.text = dados["nome"]
		botao.pressed.connect(func(): _ao_clicar_termo(termo))
		_lista_termos.add_child(botao)
		_mapa_botoes_termos[termo] = botao
	
	_termos_apreendidos = Global.glossario.obter_lista_termos_aprendidos()
	_indice_termo_atual = 0
	_atualizar_lista_termos()

func _inicializar_missoes():
	for botao in _lista_termos.get_children():
		botao.queue_free()
	
	_mapa_botoes_termos.clear()

	for missao in Global.glossario.obter_lista_missoes():
		var dados = Global.glossario.obter_dados_missao(missao)

		var botao = CenaBotaoListaGlossario.instantiate()
		botao.text = dados["nome"]
		botao.pressed.connect(func(): _ao_clicar_termo(missao))
		_lista_termos.add_child(botao)
		_mapa_botoes_termos[missao] = botao
	
	_termos_apreendidos = Global.glossario.obter_lista_missoes()
	_indice_termo_atual = 0
	_atualizar_lista_termos()

func _tocar_animacao(nome: String) -> void:
	_livro_animado.tocar(nome, false)
	await _livro_animado.animacao_finalizada

func abrir_glossario():
	await _tocar_animacao("abrir")
	
	if _indice_secao_atual == 0:
		_inicializar_glossario()
	elif _indice_secao_atual == 1:
		_inicializar_missoes()
		
	await _exibir_termo_atual()
	
func _ao_fechar_glossario():
	_limpar_texto_livro()
	await _tocar_animacao("fechar")
	hide()
	Global.emit_signal("glossario_fechado")
	
	if get_tree().paused:
		var menu_pause = get_parent().get_node_or_null("Interface_Pause_Menu")
		if menu_pause:
			menu_pause.show()

# --- LÓGICA DA ROLETA DAS SESSÕES ---
func _mudar_secao(passo_direcao: int):
	_limpar_texto_livro()
	for botao in _lista_termos.get_children():
		botao.queue_free()
	_mapa_botoes_termos.clear()
	
	var total_secoes = _secoes_disponiveis.size()
	_indice_secao_atual = (_indice_secao_atual + passo_direcao + total_secoes) % total_secoes
	
	if _livro_animado.has_method("set_speed_scale"):
		_livro_animado.speed_scale = 0.5 
		
	_livro_animado.flip_h = (passo_direcao < 0) 
	_livro_animado.tocar("passar_pagina", false)
	await _livro_animado.animacao_finalizada
	_livro_animado.flip_h = false 
	
	if _livro_animado.has_method("set_speed_scale"):
		_livro_animado.speed_scale = 1.0 # Reseta a velocidade
	
	if _titulo_glossario != null:
		_titulo_glossario.text = _secoes_disponiveis[_indice_secao_atual]

	# --- [ATUALIZADO] Carrega os dados dependendo da seção ---
	if _indice_secao_atual == 0:
		_inicializar_glossario()
		await _exibir_termo_atual()
	elif _indice_secao_atual == 1:
		_inicializar_missoes()
		await _exibir_termo_atual()

func _ao_clicar_botao_direita():
	await _mudar_secao(1)

func _ao_clicar_botao_esquerda():
	await _mudar_secao(-1)
