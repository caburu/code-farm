extends Node

var retomando_missao: bool = false
# Pontos de retomada de missões que transformam objetos do mundo.
var progresso_missoes: Dictionary = {}

const CAMINHO_SAVE = "user://save_jogo.gd"
const QUANTIDADE_MISSOES = 5
const MISSAO_INICIAL = 0

var _save_jogo: SaveJogo
var missao_atual: int
var glossario: Glossario
var inventario: Inventario
var nome_fazenda_atual: String = "Fazenda Code Farm"
var nome_jogador: String = "Jogador"
var posicao_player_atual: Vector2 = Vector2.ZERO
var slot_jogo_atual: int = 1
# Quando um save é carregado, aqui fica a quantidade de moedas presente naquele save.
# Valor -1 indica que não há quantidade de moedas pendente para aplicar ao jogador.
var ultima_quantidade_moedas: int = -1
var moedas_descobertas: bool = false:
	set(valor):
		if moedas_descobertas == valor:
			return
		moedas_descobertas = valor
		descoberta_moedas_atualizada.emit(valor)

# _________________________ NOMES DE PERSONAGENS _________________________ #
var foto_jogador = "res://assets/imagens/interface/foto_jogador.png"
var nome_robo = "AGR.O"
var foto_robo = "res://assets/imagens/interface/foto_robo.png"
var nome_avo = "Julio"
var foto_avo = "res://assets/imagens/interface/foto_avo.png"

# _________________________ GERENCIAMENTO DE SINAIS PROPAGADOS _________________________ #

signal voltar_menu_principal
signal novo_jogo
signal continuar_jogo
signal abrir_glossario
signal glossario_fechado
signal missao_fechada
signal missao_concluida
signal item_modificado(pilha: PilhaItens)
signal solicitar_dados_requisicao
signal dados_requisicao_prontos(dados: Dictionary)
signal indice_atualizado(indice: int)
signal iniciar_dialogo_npc(npc)
signal fim_dialogo_npc
signal atualizar_moedas(quantidade_moedas: int)
signal descoberta_moedas_atualizada(descobertas: bool)

func _ready() -> void:
	glossario = Glossario.new()
	inventario = Inventario.new()
	
func conectar_sinal(objeto: Object, sinal: String, funcao: Callable) -> void:
	if objeto != null and not objeto.is_connected(sinal, funcao):
		objeto.connect(sinal, funcao)

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

func salvar_jogo(slot_id: int, posicao_player: Vector2, quantidade_moedas: int = -1) -> void:
	var novo_save = SaveJogo.new()
	novo_save.versao_save = 2
	novo_save.inventario_dados = inventario.obter_dados_save()
	novo_save.indice_hotbar = inventario.indice
	novo_save.progresso_missoes = progresso_missoes.duplicate(true)
	var mundo = get_tree().get_first_node_in_group("MundoPersistente")
	if mundo:
		novo_save.mundo_dados = mundo.obter_dados_save()
		novo_save.terreno_player = mundo.jogador.terreno_atual
		novo_save.direcao_player = mundo.jogador._direcao_animacao
		posicao_player = mundo.jogador.global_position
	
	# Preenche os dados
	novo_save.nome_fazenda = nome_fazenda_atual
	novo_save.nome_jogador = nome_jogador
	novo_save.missao_atual = missao_atual
	novo_save.moedas_descobertas = moedas_descobertas
	novo_save.player_posicao = posicao_player
	# Se foi passado um valor específico de moedas, usa; senão tenta obter o valor do jogador na cena
	if quantidade_moedas >= 0:
		novo_save.quantidade_moedas = quantidade_moedas
	else:
		# Tenta localizar o jogador na cena e obter suas moedas
		var jogadores = get_tree().get_nodes_in_group("Jogador")
		if jogadores.size() > 0:
			var jogador_no_jogo = jogadores[0]
			novo_save.quantidade_moedas = jogador_no_jogo.obter_moedas()
		else:
			# Não encontrou jogador na árvore — usa 50 como fallback
			novo_save.quantidade_moedas = 50
	
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

func deletar_save(slot_id: int) -> void:
	var caminho = obter_caminho_save(slot_id)
	
	# Verifica se o arquivo realmente existe antes de tentar apagar
	if FileAccess.file_exists(caminho):
		# No Godot 4, usamos DirAccess para apagar arquivos do computador
		var erro = DirAccess.remove_absolute(caminho)
		
		if erro == OK:
			print("Save do Slot ", slot_id, " deletado com sucesso!")
		else:
			print("Erro ao tentar deletar o save do Slot ", slot_id)
	else:
		print("Nenhum save encontrado no Slot ", slot_id, " para deletar.")
# No Global.gd

func carregar_jogo(slot_id: int) -> bool:
	var caminho = obter_caminho_save(slot_id)
	
	if ResourceLoader.exists(caminho):
		_save_jogo = ResourceLoader.load(caminho, "", ResourceLoader.CACHE_MODE_IGNORE) as SaveJogo
		if _save_jogo == null:
			return false
		progresso_missoes = _save_jogo.progresso_missoes.duplicate(true)
		retomando_missao = false
		inventario.restaurar_dados_save(_save_jogo.inventario_dados, _save_jogo.indice_hotbar)
		
		missao_atual = _save_jogo.missao_atual
		nome_fazenda_atual = _save_jogo.nome_fazenda
		nome_jogador = _save_jogo.nome_jogador
		
		posicao_player_atual = _save_jogo.player_posicao
		ultima_quantidade_moedas = _save_jogo.quantidade_moedas
		Global.emit_signal("atualizar_moedas", ultima_quantidade_moedas)
		# Saves antigos após a missão 1 já passaram pela descoberta.
		moedas_descobertas = _save_jogo.moedas_descobertas or missao_atual > 1
		
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
		if save_temp == null:
			return {"existe": false}
		return {
			"existe": true,
			"nome_fazenda": save_temp.nome_fazenda,
			"nome_jogador": save_temp.nome_jogador,
			"missao": save_temp.missao_atual,
			"data_hora": save_temp.data_hora,
			"quantidade_moedas": save_temp.quantidade_moedas
		}
	else:
		return {"existe": false}

func resetar_dados_novo_jogo() -> void:
	print("Iniciando reset dos dados globais...")
	
	missao_atual = MISSAO_INICIAL
	moedas_descobertas = false
	ultima_quantidade_moedas = -1
	retomando_missao = false
	progresso_missoes.clear()
	nome_fazenda_atual = "Fazenda Code Farm"
	posicao_player_atual = Vector2.ZERO
	
	glossario = Glossario.new()
	inventario.restaurar_dados_save([])
	nome_jogador = "Jogador"
	
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


func restaurar_mundo_carregado(mundo: MundoJogo) -> void:
	if _save_jogo == null:
		return
	mundo.jogador.terreno_atual = _save_jogo.terreno_player
	mundo.jogador._direcao_animacao = _save_jogo.direcao_player
	if _save_jogo.versao_save >= 2 and not _save_jogo.mundo_dados.is_empty():
		mundo.restaurar_dados_save(_save_jogo.mundo_dados)
	else:
		mundo.restaurar_progresso_antigo()
		
	if missao_atual == 0:
		var diario = mundo.obter_elemento("Missao0")
		if diario:
			diario.show()
			diario.process_mode = Node.PROCESS_MODE_INHERIT


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
#|__ global.gd
