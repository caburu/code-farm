class_name InterfaceGlossario

extends Control

@onready var CenaBotaoListaGlossario: PackedScene = preload("res://interface_jogo/interface_Pause_Menu/botao_lista_glossario/botao_lista_glossario.tscn")

@onready var _lista_termos: VBoxContainer = %ListaTermos
@onready var _livro_animado: AnimatedTextureRect = %LivroAnimado
@onready var _pagina_descricao_livro: RichTextLabel = %DescricaoComando
@onready var _pagina_exemplo_livro: RichTextLabel = %ExemploComando

var _mapa_botoes_termos: Dictionary = {}
var _indice_termo_atual: int = 0
var _termos_apreendidos: Array = []

func _ready():
	_aplicar_corte_em_todos_os_frames()
	_limpar_texto_livro()
	Global.emit_signal("glossario_fechado")

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
	for termo in _mapa_botoes_termos.keys():
		var botao = _mapa_botoes_termos[termo]
		if filtro == "" or termo.to_lower().contains(filtro.to_lower()):
			botao.show()
		else:
			botao.hide()

	_termos_apreendidos.clear()
	for termo in Global.glossario.obter_lista_termos_aprendidos():
		if filtro == "" or termo.to_lower().contains(filtro.to_lower()):
			_termos_apreendidos.append(termo)

func _destacar_botao_termo(termo: String):
	for t in _mapa_botoes_termos.keys():
		var botao = _mapa_botoes_termos[t] as BotaoListaGlossario
		botao.desativar_modo_selecionado()

	if _mapa_botoes_termos.has(termo):
		var botao = _mapa_botoes_termos[termo] as BotaoListaGlossario
		botao.ativar_modo_selecionado()

func _ao_clicar_termo(termo: String):
	var indice_destino = Global.glossario.obter_lista_termos_aprendidos().find(termo)
	await _folhear_paginas_para(indice_destino)
	_termos_apreendidos = Global.glossario.obter_lista_termos_aprendidos()
	_indice_termo_atual = indice_destino
	_destacar_botao_termo(termo)
	await _exibir_termo_no_livro(termo)

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

func _exibir_termo_no_livro(termo: String) -> void:
	var dados = Global.glossario.obter_dados_termo(termo)
	_limpar_texto_livro()
	
	_pagina_descricao_livro.text = dados["nome"] + ":\n\n" + dados["descricao"]
	_pagina_exemplo_livro.text = "Exemplo:\n\n" + dados["exemplo"]

func _ao_mudar_texto_campo_pesquisa(novo_texto: String) -> void:
	_atualizar_lista_termos(novo_texto)

func _exibir_termo_atual() -> void:
	if _indice_termo_atual >= 0 and _indice_termo_atual < _termos_apreendidos.size():
		var termo = _termos_apreendidos[_indice_termo_atual]
		_destacar_botao_termo(termo)
		await _exibir_termo_no_livro(termo)

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

#func _ao_fechar_glossario():
	#_limpar_texto_livro()
	#await _tocar_animacao("fechar")
	#hide()
	#Global.emit_signal("glossario_fechado")
	

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
	
func _tocar_animacao(nome: String) -> void:
	_livro_animado.tocar(nome, false)
	await _livro_animado.animacao_finalizada

func abrir_glossario():
	await _tocar_animacao("abrir")
	
	_inicializar_glossario()
	
	await _exibir_termo_atual()
	
func _ao_fechar_glossario():
	_limpar_texto_livro()
	await _tocar_animacao("fechar")
	hide()
	Global.emit_signal("glossario_fechado")
	
	# --- MUDANÇA AQUI ---
	# Ao fechar o glossário, verificamos se o jogo está pausado.
	# Se estiver pausado, significa que viemos do Menu de Pausa, então reabrimos ele.
	if get_tree().paused:
		# Tenta encontrar o menu de pausa irmão e mostrar
		# O caminho "../Interface_Pause_Menu" depende do nome exato do seu nó na cena
		var menu_pause = get_parent().get_node_or_null("Interface_Pause_Menu")
		if menu_pause:
			menu_pause.show()
