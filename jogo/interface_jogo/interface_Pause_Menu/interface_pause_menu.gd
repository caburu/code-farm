extends Control

@export var interface_glossario: Control

func _ready():
	# Garante que o menu comece escondido e o jogo rodando
	hide()
	get_tree().paused = false

func _unhandled_input(event):
	# "ui_cancel" é o padrão do Godot para a tecla ESC
	if event.is_action_pressed("ui_cancel"):
		alternar_pausa()

func alternar_pausa():
	# Inverte o estado atual (se está pausado, despausa. Se está rodando, pausa)
	var estado_pause = not get_tree().paused
	get_tree().paused = estado_pause
	
	# Se pausou, mostra o menu. Se despausou, esconde.
	visible = estado_pause

# Esta função será conectada ao botão "Continuar"
func _on_botao_continuar_pressed():
	alternar_pausa()
	
func _on_botao_diario_pressed():
	# 1. Esconde o menu de pausa (mas mantem o jogo pausado)
	hide()
	
	# 2. Abre o glossário
	if interface_glossario:
		interface_glossario.abrir_glossario()
		interface_glossario.show()


func _on_botao_menu_pressed() -> void:
	hide() # Esconde o pause
	get_tree().paused = false # Despausa o jogo
	Global.emit_signal("voltar_menu_principal") # Avisa o gerenciador


func _on_botao_salvar_pressed() -> void:
	hide() 
	get_parent().abrir_menu_save_load(true)


func _on_botao_carregar_pressed() -> void:
	hide() 
	get_parent().abrir_menu_save_load(false)
