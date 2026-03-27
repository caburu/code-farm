extends Node

var retomando_missao: bool = false

const CAMINHO_SAVE = "user://save_jogo.gd"
const QUANTIDADE_MISSOES = 5
const MISSAO_INICIAL = 1

var _save_jogo: SaveJogo
var missao_atual: int
var glossario: Glossario = Glossario.new()
var inventario: Inventario = Inventario.new()
var nome_fazenda_atual: String = "Fazenda Code Farm"
var posicao_player_atual: Vector2 = Vector2.ZERO
var slot_jogo_atual: int = 1

# _________________________ GERENCIAMENTO DE SINAIS PROPAGADOS _________________________ #

signal voltar_menu_principal
signal novo_jogo
signal continuar_jogo
signal abrir_glossario
signal glossario_fechado
signal missao_fechada
signal missao_concluida
signal item_adicionado(pilha: PilhaItens)
signal solicitar_dados_requisicao
signal dados_requisicao_prontos(dados: Dictionary)

func conectar_sinal(no: Node, sinal: String, funcao: Callable) -> void:
	if no != null and not no.is_connected(sinal, funcao):
		no.connect(sinal, funcao)

func propagar_sinal(sinal: String, emissor: Node) -> void:
	if emissor == null:
		push_error("Tentativa de propagar sinal '%s' de um emissor nulo." % sinal)
		return

	var callback := func() -> void:
		if has_signal(sinal):
			emit_signal(sinal)
		else:
			push_error("Globals: sinal '%s' não declarado para propagação!" % sinal)

	var callable := Callable(callback)

	if not emissor.is_connected(sinal, callable):
		emissor.connect(sinal, callable)

# _________________________ GERENCIAMENTO DE MISSOES _________________________ #

func concluiu_todas_missoes() -> bool:
	return missao_atual > QUANTIDADE_MISSOES

# _________________________ GERENCIAMENTO DE SAVE _________________________ #

func obter_caminho_save(slot_id: int) -> String:
	return "user://save_slot_%d.tres" % slot_id

func salvar_jogo(slot_id: int, posicao_player: Vector2) -> void:
	var novo_save = SaveJogo.new()
	
	# Preenche os dados
	novo_save.nome_fazenda = nome_fazenda_atual
	novo_save.missao_atual = missao_atual
	novo_save.player_posicao = posicao_player
	novo_save.data_hora = Time.get_datetime_dict_from_system()
	
	slot_jogo_atual = slot_id 
	print("Salvando no slot: ", slot_id)
	
	# Salva no arquivo com o número do slot correto
	var caminho = obter_caminho_save(slot_id)
	var erro = ResourceSaver.save(novo_save, caminho)
	
	if erro == OK:
		print("Jogo salvo com sucesso no Slot ", slot_id)
	else:
		print("Erro ao salvar no Slot ", slot_id)

# No Global.gd

func carregar_jogo(slot_id: int) -> bool:
	var caminho = obter_caminho_save(slot_id)
	
	if ResourceLoader.exists(caminho):
		_save_jogo = ResourceLoader.load(caminho) as SaveJogo
		
		# Restaura os dados globais
		missao_atual = _save_jogo.missao_atual
		nome_fazenda_atual = _save_jogo.nome_fazenda
		
		posicao_player_atual = _save_jogo.player_posicao
		
		slot_jogo_atual = slot_id 
		
		print("Save carregado do Slot ", slot_id)
		return true
	else:
		print("Save não encontrado no Slot ", slot_id)
		return false
		
func verificar_dados_slot(slot_id: int) -> Dictionary:
	var caminho = obter_caminho_save(slot_id)
	if ResourceLoader.exists(caminho):
		
		var save_temp = ResourceLoader.load(caminho, "", ResourceLoader.CACHE_MODE_IGNORE) as SaveJogo
		
		return {
			"existe": true,
			"nome_fazenda": save_temp.nome_fazenda,
			"missao": save_temp.missao_atual,
			"data_hora": save_temp.data_hora # 👈 ADICIONAR ISSO
		}
	else:
		return {"existe": false}

func resetar_dados_novo_jogo() -> void:
	print("Iniciando reset dos dados globais...")
	
	missao_atual = MISSAO_INICIAL
	retomando_missao = false
	
	glossario = Glossario.new()
	inventario = Inventario.new()
	
	_save_jogo = null
	
	print("Dados resetados com sucesso!")
	
func obter_slot_mais_recente() -> int:
	var slot_mais_recente = -1
	var tempo_mais_recente = 0
	
	# Slot 0 = Auto Save
	# Slots 1-5 = Saves Manuais
	for i in range(0, 6):
		var caminho = obter_caminho_save(i)
		
		if FileAccess.file_exists(caminho):
			
			var modificado_em = FileAccess.get_modified_time(caminho)
			
			if modificado_em > tempo_mais_recente:
				tempo_mais_recente = modificado_em
				slot_mais_recente = i
				
	return slot_mais_recente
#Estrutura do projeto:

#jogo
#|__ assets
	#|__ fontes ...
	#|__ imagens ...
	#|__ sons ...
#
#|__ gerenciador_jogo
	#|__ glossario 
		#|__ glossario.gd
	#|__ inventario
		#|__ inventario.gb
		#|__ item.gd
		#|__ pilha_itens.gd
	#|__ missoes
		#|__ roteiros
			#|__ missao1.gd
			#|__ missao2.gd
			#|__ ...
		#|__ gerenciador_missoes.gd
		#|__ resultado_api.gd
		#|__ roteiro_missao.gd
	#|__ save
		#|__ save_jogo.gd
	#|__ gerenciador_jogo.gd
	#|__ gerenciador_jogo.tscn
#
#|__ interface_jogo
	#|__ interface_glossario
		#|__ interface_glossario.gd
		#|__ interface_glossario.tscn
		#|__ botao_lista_glossario
			#|__ botao_lista_glossario.gd
			#|__ botao_lista_glossario.tscn
		#|__ textura_animada_interface
			#|__ textura_animada_interface.gd
			#|__ textura_animada_interface.tscn		
	#|__ interface_menu_inicial
		#|__ interface_menu_inicial.gd
		#|__ interface_menu_inicial.tscn
	#|__ interface_missao
		#|__ caixa_dialogo.gd
		#|__ editor_codigo.gd
		#|__ tooltip.gd
		#|__ python_syntax_highlighter.gd
		#|__ interface_missao.gd
		#|__ interface_missao.tscn
	#|__ interface_padrao
		#|__ slot_hotbar
			#|__ slot_hotbar.gd
			#|__ slot_hotbar.tscn
		#|__ hotbar.gd
		#|__ menu_superior.gd
		#|__ interface_padrao.tscn
	#|__ interface_jogo.gd
	#|__ interface_jogo.tscn 
#
#|__ mundo_jogo
	#|__ animacoes ...
	#|__ jogador
		#|__ jogador.gd
		#|__ jogador.tscn
	#|__ objeto_coletavel
		#|__ objetos ...
		#|__ objeto_coletavel.gd
		#|__ objeto_coletavel.tscn
	#|__ objeto_interativo
		#|__ objeto_interativo.gd
		#|__ objeto_interativo.tscn
	#|__ passagem
		#|__ passagem.gd
		#|__ passagem.tscn
	#|__ terrenos
		#|__ terreno_casa.gd
		#|__ terreno_fazenda.tscn
	#|__ mundo_jogo.gd
	#|__ mundo_jogo.tscn
#
#|__ global.gb
