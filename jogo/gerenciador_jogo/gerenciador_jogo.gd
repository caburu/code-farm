class_name GerenciadorJogo 

extends Node
@export var cena_mundo_modelo: PackedScene

var mundo_jogo: MundoJogo 
var _glossario_aberto: bool = false

@onready var interface_jogo: InterfaceJogo = $CanvasLayer/InterfaceJogo
@onready var _gerenciador_missoes: GerenciadorMissoes
@onready var _gerenciador_npcs: GerenciadorNPCs
@onready var interface_bau: InterfaceBau = $CanvasLayer/InterfaceJogo/InterfaceBau
@onready var interface_bancada: InterfaceBancada = $CanvasLayer/InterfaceJogo/InterfaceBancada

func _ready() -> void:
	
	mundo_jogo = $MundoJogo
	
	_gerenciador_missoes = GerenciadorMissoes.new()
	
	_gerenciador_npcs = GerenciadorNPCs.new()
	
	interface_jogo.exibir_interface(interface_jogo.Interface.MENU_INICIAL)
	
	Global.conectar_sinal(Global, "novo_jogo", Callable(self, "_ao_clicar_novo_jogo"))
	Global.conectar_sinal(Global, "continuar_jogo", Callable(self, "_ao_clicar_continuar_jogo"))
	Global.conectar_sinal(Global, "abrir_glossario", Callable(self, "_ao_clicar_botao_glossario"))
	Global.conectar_sinal(Global, "missao_fechada", Callable(self, "_ao_clicar_fechar_missao"))
	Global.conectar_sinal(Global, "voltar_menu_principal", Callable(self, "_ao_voltar_menu_principal"))
	Global.conectar_sinal(Global, "fim_dialogo_npc", Callable(self, "_ao_clicar_fechar_missao"))
	
func _ao_clicar_novo_jogo() -> void:
	Global.resetar_dados_novo_jogo()
	await _trocar_mundo_para_novo()
	get_tree().paused = false
	interface_jogo.exibir_interface(interface_jogo.Interface.PADRAO)
	_gerenciador_missoes.executar()

# No gerenciador_jogo.gd

func _trocar_mundo_para_novo() -> void:
	_gerenciador_missoes.reiniciar()
	if is_instance_valid(_gerenciador_npcs):
		_gerenciador_npcs.free()
	_gerenciador_npcs = GerenciadorNPCs.new()
	interface_bancada.fechar()
	if mundo_jogo:
		mundo_jogo.queue_free()
		await get_tree().process_frame 
	
	mundo_jogo = cena_mundo_modelo.instantiate()
	add_child(mundo_jogo)
	move_child(mundo_jogo, 0)
	
	# --- O SEGREDO ESTÁ AQUI ---
	# Espere o mundo entrar na árvore antes de mandar as missões procurarem coisas nele
	await get_tree().process_frame 
	
	# Agora sim configura e executa
	_gerenciador_missoes.configurar(mundo_jogo, interface_jogo)
	_gerenciador_npcs.configurar(mundo_jogo, interface_jogo)
	_conectar_baus()
	_conectar_bancadas()

func _ao_clicar_continuar_jogo() -> void:
	await _trocar_mundo_para_novo()
	
	if mundo_jogo and mundo_jogo.jogador:
		mundo_jogo.jogador.global_position = Global.posicao_player_atual
		# Se houve uma quantidade de moedas carregada do save, aplica ao jogador
		if Global.ultima_quantidade_moedas >= 0:
			mundo_jogo.jogador.definir_moedas(Global.ultima_quantidade_moedas)
			# Reseta o valor para evitar reaplicação
			Global.ultima_quantidade_moedas = -1
		Global.restaurar_mundo_carregado(mundo_jogo)
		
	interface_jogo.exibir_interface(interface_jogo.Interface.PADRAO)
	_gerenciador_missoes.executar()
	
	get_tree().paused = false

func _ao_clicar_botao_glossario() -> void:
	if _glossario_aberto:
		return

	_glossario_aberto = true

	var jogador := mundo_jogo.obter_jogador()
	var movimento_estava_liberado := jogador.pode_interagir()
	var bancada_estava_aberta := interface_bancada.visible
	var bau_estava_aberto := interface_bau.visible
	var interface_anterior := interface_jogo.obter_interface_atual()

	jogador.desativar_movimento()

	interface_bancada.hide()
	interface_bau.hide()
	interface_jogo.exibir_interface(InterfaceJogo.Interface.GLOSSARIO)

	await Global.glossario_fechado

	interface_jogo.exibir_interface(interface_anterior)

	if bancada_estava_aberta:
		interface_bancada.show()
		interface_jogo.obter_interface(InterfaceJogo.Interface.PADRAO).hide()

	if bau_estava_aberto:
		interface_bau.show()

	if is_instance_valid(jogador) and movimento_estava_liberado:
		jogador.ativar_movimento()

	_glossario_aberto = false

func _ao_clicar_fechar_missao() -> void:
	mundo_jogo.ativar_movimento_jogador()
	interface_jogo.exibir_interface(InterfaceJogo.Interface.PADRAO)
	
func _ao_voltar_menu_principal() -> void:
	interface_bancada.fechar()
	if mundo_jogo and mundo_jogo.has_method("desativar_movimento_jogador"):
		mundo_jogo.desativar_movimento_jogador()
		
	interface_jogo.exibir_interface(interface_jogo.Interface.MENU_INICIAL)

@warning_ignore("unused_parameter")
func _process(delta):
	if interface_jogo.obter_interface_atual() == interface_jogo.Interface.PADRAO:
		if mundo_jogo and is_instance_valid(mundo_jogo.jogador):
			Global.posicao_player_atual = mundo_jogo.jogador.global_position
			
func _conectar_baus() -> void:
	for objeto in get_tree().get_nodes_in_group("Baus"):
		var bau = objeto as Bau

		if bau == null:
			continue

		Global.conectar_sinal(bau,"abertura_solicitada",Callable(interface_bau, "abrir"))

func _conectar_bancadas() -> void:
	for objeto in get_tree().get_nodes_in_group("Bancadas"):
		var bancada = objeto as Bancada

		if bancada == null:
			continue

		Global.conectar_sinal(
			bancada,
			"abertura_solicitada",
			Callable(interface_bancada, "abrir")
		)
