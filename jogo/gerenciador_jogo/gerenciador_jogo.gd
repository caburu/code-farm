class_name GerenciadorJogo 

extends Node
@export var cena_mundo_modelo: PackedScene

var mundo_jogo: MundoJogo 

@onready var interface_jogo: InterfaceJogo = $CanvasLayer/InterfaceJogo
@onready var _gerenciador_missoes: GerenciadorMissoes

func _ready() -> void:
	
	mundo_jogo = $MundoJogo
	
	_gerenciador_missoes = GerenciadorMissoes.new()
	_gerenciador_missoes.configurar(mundo_jogo, interface_jogo)
	
	interface_jogo.exibir_interface(interface_jogo.Interface.MENU_INICIAL)
	
	Global.conectar_sinal(Global, "novo_jogo", Callable(self, "_ao_clicar_novo_jogo"))
	Global.conectar_sinal(Global, "continuar_jogo", Callable(self, "_ao_clicar_continuar_jogo"))
	Global.conectar_sinal(Global, "abrir_glossario", Callable(self, "_ao_clicar_botao_glossario"))
	Global.conectar_sinal(Global, "missao_fechada", Callable(self, "_ao_clicar_fechar_missao"))
	Global.conectar_sinal(Global, "voltar_menu_principal", Callable(self, "_ao_voltar_menu_principal"))
	
func _ao_clicar_novo_jogo() -> void:
	Global.resetar_dados_novo_jogo()
	await _trocar_mundo_para_novo()
	interface_jogo.exibir_interface(interface_jogo.Interface.PADRAO)
	_gerenciador_missoes.executar()

# No gerenciador_jogo.gd

func _trocar_mundo_para_novo() -> void:
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

func _ao_clicar_continuar_jogo() -> void:
	await _trocar_mundo_para_novo()
	
	if mundo_jogo and mundo_jogo.jogador:
		mundo_jogo.jogador.global_position = Global.posicao_player_atual
		
	interface_jogo.exibir_interface(interface_jogo.Interface.PADRAO)
	_gerenciador_missoes.executar()
	
	get_tree().paused = false

func _ao_clicar_botao_glossario() -> void:
	mundo_jogo.desativar_movimento_jogador()

	var interface_anterior: InterfaceJogo.Interface = interface_jogo.obter_interface_atual()
	interface_jogo.exibir_interface(InterfaceJogo.Interface.GLOSSARIO)

	await Global.glossario_fechado

	interface_jogo.exibir_interface(interface_anterior)
	mundo_jogo.ativar_movimento_jogador()

func _ao_clicar_fechar_missao() -> void:
	mundo_jogo.ativar_movimento_jogador()
	interface_jogo.exibir_interface(InterfaceJogo.Interface.PADRAO)
	
func _ao_voltar_menu_principal() -> void:
	if mundo_jogo and mundo_jogo.has_method("desativar_movimento_jogador"):
		mundo_jogo.desativar_movimento_jogador()
		
	interface_jogo.exibir_interface(interface_jogo.Interface.MENU_INICIAL)

func _process(delta):
	# Se o mundo e o jogador existem, atualize a posição no Global
	if mundo_jogo and is_instance_valid(mundo_jogo.jogador):
		Global.posicao_player_atual = mundo_jogo.jogador.global_position
