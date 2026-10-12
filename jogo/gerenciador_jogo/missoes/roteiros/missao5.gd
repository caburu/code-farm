extends RoteiroMissao

func executar() -> void:
	await dialogo("Ei! Olha só o quintal! Suas alfaces estão crescendo rápido, mas precisam de água todos os dias.")
	await dialogo("São cinco cabeças de alface... Regar uma por uma com um comando separado seria bem cansativo, né?")
	await dialogo("Imagine se você tivesse que escrever um comando pra cada uma, assim:")
	await codigo("print(\"Regando alface 1\")
print(\"Regando alface 2\")
print(\"Regando alface 3\")
print(\"Regando alface 4\")
print(\"Regando alface 5\")
")
	await dialogo("Funciona, mas é meio repetitivo... e se fossem 50 alfaces?")
	await dialogo("É por isso que em programação usamos estruturas de repetição! Com o for, você consegue repetir uma tarefa várias vezes com pouquíssimas linhas.")
	await dialogo("O comando for permite repetir uma ação um número determinado de vezes.")
	await dialogo("Por exemplo, se você quiser empilhar 3 caixas, pode escrever assim:")
	await codigo('for i in range(3):
	print("Empilhando caixa número", i)
')
	await dialogo("Esse código vai repetir a frase 3 vezes, mudando o número automaticamente: 0, 1 e 2.")
	await dialogo("A variável `i` vai mudando a cada repetição, seguindo os números do `range`.")
	await dialogo("Vamos por isso em prática! Escreva um código que use for para regar todas as alfaces do quintal. Use print() para exibir qual alface está sendo regada!")

	var sucesso = false
	while not sucesso:
		var resultado = await obter_codigo_analisado()

		# Casos sem animação
		if resultado.status in [ResultadoAPI.Status.ERRO_SINTATICO, ResultadoAPI.Status.ERRO_DESCONHECIDO]:
			for mensagem in resultado.mensagens:
				await dialogo(mensagem)
			continue

		# Caso de sucesso
		if resultado.status == ResultadoAPI.Status.SUCESSO:
			var quantidade_regas = resultado.dados.get("quantidade_regas", 0)
			await _tocar_animacao_regar(quantidade_regas)
			await dialogo("Parabéns, jardineiro-programador! Agora você sabe como usar o for para repetir ações automaticamente!")
			await dialogo("Com esse conhecimento, vai ficar bem mais fácil automatizar tarefas repetitivas. E isso é só o começo!")
			sucesso = true

		# Caso de erro semântico
		elif resultado.status == ResultadoAPI.Status.ERRO_SEMANTICO:
			var erro = resultado.dados.get("erro", "")
			var quantidade_regas = resultado.dados.get("quantidade_regas", null)

			if erro == "faltou_for":
				await _tocar_animacao_regar(0)
				await dialogo("Ei! Parece que você esqueceu de usar o comando 'for'. Tente usá-lo para repetir a ação de regar as alfaces.")

			elif erro == "faltou_print":
				await _tocar_animacao_regar(5, true)
				await dialogo("Você andou pelas alfaces, mas não disse qual estava regando! Não esqueça do print!")

			elif quantidade_regas != null:
				var regar_ate = min(quantidade_regas, 6)
				await _tocar_animacao_regar(regar_ate)

				if quantidade_regas < 5:
					await dialogo("Você regou menos alfaces do que deveria! Tente ajustar o range para pegar as 5.")
				elif quantidade_regas > 5:
					await dialogo("Você regou demais! Tente limitar o range para regar apenas as 5 cabeças de alface.")

			# Mensagens adicionais do backend
			for mensagem in resultado.mensagens:
				await dialogo(mensagem)
	
	concluir_missao()

func _tocar_animacao_regar(quantidade: int, sem_regar := false) -> void:
	var jogador = mundo_jogo.obter_jogador()
	var primeira_alface = mundo_jogo.obter_objeto_interativo_atual()
	if primeira_alface == null:
		push_warning("Não foi possível encontrar a alface inicial.")
		return
		
	var largura = primeira_alface.obter_largura()
	var pos_inicial_jogador = primeira_alface.global_position + Vector2(-largura / 2 - 4, 0)
	
	await jogador.mover_para(pos_inicial_jogador, 0.5)
	jogador.tocar_animacao("parado_direita", "direita")
	await mundo_jogo.get_tree().create_timer(0.4).timeout
	
	var total_regar = min(quantidade, 5)
		
	# Rega até 5
	for i in range(total_regar):
		var pos_regar = pos_inicial_jogador + Vector2(i * largura, 0)
		await jogador.mover_para(pos_regar, 0.4)
		if not sem_regar:
			jogador.tocar_animacao("usando_regador_direita", "direita")
		await mundo_jogo.get_tree().create_timer(0.8).timeout

	# Faltou regar: mostrar X nas alfaces faltantes
	if quantidade < 5 and not sem_regar:
		for i in range(quantidade, 5):
			var pos_erro = primeira_alface.global_position + Vector2(i * largura -4 , -12)
			_exibir_x_em_posicao(pos_erro)

	# Excesso: mostrar o x somente uma vez após a 5ª alface
	elif quantidade > 5 and not sem_regar:
		var pos_erro = primeira_alface.global_position + Vector2(5 * largura -4, -12)
		_exibir_x_em_posicao(pos_erro)
		
	#Volta ao início
	await mundo_jogo.get_tree().create_timer(2).timeout
	await jogador.mover_para(pos_inicial_jogador, 0.6)
	jogador.tocar_animacao("parado_direita", "direita")

func _exibir_x_em_posicao(posicao: Vector2) -> void:
	var label = Label.new()
	label.text = "X"
	label.modulate = Color.RED
	label.z_index = 1

	var settings = LabelSettings.new()
	settings.font_size = 16
	label.label_settings = settings

	mundo_jogo.add_child(label)

	var label_size = label.get_minimum_size()
	label.global_position = posicao

	var tween = mundo_jogo.create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 8)
	tween.tween_callback(label.queue_free)

func mover_para(alvo: Node2D, destino: Vector2, duracao: float) -> void:
	var tween = mundo_jogo.create_tween()
	tween.tween_property(alvo, "global_position", destino, duracao).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
