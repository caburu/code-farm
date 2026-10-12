extends Control

func _input(event):
	# A condição "visible" garante que o ENTER só funcione se a tela de história estiver na tela
	if visible and event.is_action_pressed("ui_accept"):
		
		# Pega a referência do pai (que é o seu InterfaceJogo)
		var gerenciador_interface = get_parent()
		
		# Muda a tela para a interface padrão do jogo (HUD, vida, etc)
		gerenciador_interface.exibir_interface(gerenciador_interface.Interface.PADRAO)
		
		Global.emit_signal("novo_jogo")
		# NOTA: É aqui que você também deve chamar a função que de fato "inicia"
		# a mecânica do jogo (ex: dar unpause no mundo, liberar a movimentação do player, etc).
