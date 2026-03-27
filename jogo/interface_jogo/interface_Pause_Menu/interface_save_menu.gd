class_name InterfaceSalvarCarregar
extends Control

@export var lista_botoes_slots: Array[Button]

@onready var container_botoes: VBoxContainer = $MarginContainer/VBoxContainer

# Variável para saber se estamos salvando ou carregando
var modo_salvar: bool = true 

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
		
		var dados = Global.verificar_dados_slot(slot_real)
		
		if dados["existe"]:
			# Se tiver save: "Slot 1 [Quebra Linha] Nome da Fazenda (Missão X)"
			var dt = dados["data_hora"]

			var data_formatada = "%02d/%02d/%04d às %02d:%02d" % [
				dt.day,
				dt.month,
				dt.year,
				dt.hour,
				dt.minute
			]

			botao.text = "%s\n%s" % [dados["nome_fazenda"],data_formatada]
		else:
			botao.text = "Save Slot %d" % slot_real # Ou "Vazio", como preferir
			
			pass

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
