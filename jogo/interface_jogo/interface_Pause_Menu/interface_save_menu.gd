class_name InterfaceSalvarCarregar
extends Control

@export var lista_botoes_slots: Array[Button]

@onready var container_botoes: VBoxContainer = $MarginContainer/VBoxContainer

# Variável para saber se estamos salvando ou carregando
var modo_salvar: bool = true 
var slot_para_excluir: int = 0

func _ready():
	hide()
	
func abrir_tela(modo_save: bool):
	modo_salvar = modo_save
	_atualizar_nomes_botoes()
	show()

func _on_save_slot_1_pressed() -> void:
	_ao_clicar_slot(1)

func _on_save_slot_2_pressed() -> void:
	_ao_clicar_slot(2)

func _on_save_slot_3_pressed() -> void:
	_ao_clicar_slot(3)

func _on_save_slot_4_pressed() -> void:
	_ao_clicar_slot(4)

func _on_save_slot_5_pressed() -> void:
	_ao_clicar_slot(5)

		
	_atualizar_nomes_botoes()
	show()

func _atualizar_nomes_botoes():
	if lista_botoes_slots.size() == 0:
		return

	for i in range(lista_botoes_slots.size()):
		var botao = lista_botoes_slots[i]
		var slot_real = i + 1 # Slot 1, 2, 3...
		
		# Pega a lixeira que está exatamente do lado deste botão de save
		# Como a lixeira é o segundo item da sua "Linha" (HBoxContainer), ela é o child(1)
		var botao_lixeira = botao.get_parent().get_child(1) 
		
		var dados = Global.verificar_dados_slot(slot_real)
		
		if dados["existe"]:
			# Tem save? Deixa a lixeira visível e clicável
			botao_lixeira.modulate.a = 1.0 # 1.0 = 100% visível
			botao_lixeira.disabled = false # Permite o clique
			
			var dt = dados["data_hora"]
			var data_formatada = "%02d/%02d/%04d às %02d:%02d" % [
				dt.day, dt.month, dt.year, dt.hour, dt.minute
			]
			botao.text = "%s\n%s\n%s" % [
				dados.get("nome_fazenda", "Fazenda"), 
				dados.get("nome_jogador", "Jogador"), 
				data_formatada
			]
			
		else:
			# Não tem save? Deixa a lixeira transparente e intocável
			botao_lixeira.modulate.a = 0.0 # 0.0 = totalmente invisível
			botao_lixeira.disabled = true  # Bloqueia o clique
			
			botao.text = "Save Slot %d" % slot_real

func _ao_clicar_slot(slot_id: int):
	print("--- INÍCIO DO PROCESSO ---")
	print("Botão Slot ", slot_id, " clicado.")
	print("Modo Salvar está ativado? ", modo_salvar)
	if modo_salvar:
		
		Global.slot_jogo_atual = slot_id
		
		Global.salvar_jogo(slot_id, Global.posicao_player_atual)
		_atualizar_nomes_botoes() # Atualiza o texto para mostrar o nome novo
		
	else:
		# Ação de CARREGAR
		var carregou = Global.carregar_jogo(slot_id)
		if carregou:
			Global.emit_signal("continuar_jogo") # Avisa o gerenciador para iniciar o jogo
			hide() # Fecha a tela
			
func _on_botao_fechar_pressed():
	hide()
	
	# Se estávamos no jogo (não no menu inicial), reabrimos o menu de pausa
	if get_tree().paused and Global.missao_atual > 0: 
		var pause_menu = get_parent().get_node_or_null("Interface_Pause_Menu")
		if pause_menu:
			pause_menu.show()
	else:
		# Se estávamos no menu inicial, volta a mostrar o menu inicial?
		# Isso depende se você ocultou o menu inicial ao abrir este.
		pass
	



func _on_botão_de_excluir_1_pressed() -> void:
	slot_para_excluir = 1
	$Fundo_confirmacao.show()


func _on_botão_de_excluir_2_pressed() -> void:
	slot_para_excluir = 2
	$Fundo_confirmacao.show()


func _on_botão_de_excluir_3_pressed() -> void:
	slot_para_excluir = 3
	$Fundo_confirmacao.show()


func _on_botão_de_excluir_4_pressed() -> void:
	slot_para_excluir = 4
	$Fundo_confirmacao.show()


func _on_botão_de_excluir_5_pressed() -> void:
	slot_para_excluir = 5
	$Fundo_confirmacao.show()

func _on_não_pressed() -> void:
	$Fundo_confirmacao.hide() # Só esconde a tela, não faz nada
	
func _on_sim_pressed() -> void:
	# Apaga o save usando o seu Global (ajuste o nome da função se for diferente no seu Global)
	Global.deletar_save(slot_para_excluir) 
	
	# Esconde a tela de confirmação
	$Fundo_confirmacao.hide()
	
	# Atualiza os textos dos botões principais para mostrar que o slot agora está "Vazio"
	_atualizar_nomes_botoes()
