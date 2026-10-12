extends RoteiroMissao

func executar() -> void:
	await dialogo("Nossa! Olha só essa bagunça na cozinha... tem copos espalhados por toda parte!")
	await dialogo("Que tal organizarmos isso? Mas antes, deixa eu te explicar uma coisa muito importante, e acho que os copos podem ajudar com isso!")
	await dialogo("Na programação, usamos algo chamado Variáveis para armazenar informações.")
	await dialogo("Uma variável é como um copo: ela tem um nome e pode conter algo dentro. Por exemplo:")
	await codigo("copo = \"água\"")
	await _tocar_animacao_copo("despejar_agua")
	await dialogo("Aqui, temos uma variável chamada copo, e ela está armazenando o valor 'água'. Mas olha só, se eu quiser trocar o que tem dentro do copo, basta fazer assim:")
	await codigo("copo = \"suco\"")
	await _tocar_animacao_copo("despejar_suco")
	await dialogo("Agora, o copo contém suco! Isso mostra que Variáveis podem mudar de valor ao longo do tempo.")
	await dialogo("Legal, né? Agora é sua vez. Crie duas Variáveis diferentes representando dois copos, e coloque suas bebidas favoritas dentro desses copos.")

	var sucesso = false
	while not sucesso:
		var resultado = await obter_codigo_analisado()
		
		if resultado.status == ResultadoAPI.Status.SUCESSO:
			await dialogo("Muito bem! Agora o seu copo possui um contudo, assim como uma variável pode conter!")
			await dialogo("Mas agora que você ja aprendeu sobre variáveis, vamos arrumar esssa cozinha!")
			await _limpar_cozinha()
			sucesso = true
		else:
			for mensagem in resultado.mensagens:
				await dialogo(mensagem)

	concluir_missao()

func _tocar_animacao_copo(nome: String) -> void:
	var copo = mundo_jogo.obter_elemento("Copo")
	if not is_instance_valid(copo):
		return
	await copo.tocar_animacao(nome)
	await mundo_jogo.get_tree().create_timer(2).timeout

func _limpar_cozinha():
	var copo = mundo_jogo.obter_elemento("Copo")
	if not is_instance_valid(copo):
		return
	var bolhas = preload("res://mundo_jogo/animacoes/bolhas/bolhas.tscn").instantiate()
	
	bolhas.visible = true
	bolhas.modulate = Color(1, 1, 1, 0)

	var tween = mundo_jogo.get_tree().create_tween()
	tween.tween_property(bolhas, "modulate:a", 1.0, 1.0)
	await tween.finished

	await mundo_jogo.get_tree().create_timer(2.0).timeout

	copo.queue_free()

	var tween_out = mundo_jogo.get_tree().create_tween()
	tween_out.tween_property(bolhas, "modulate:a", 0.0, 1.0)
	await tween_out.finished

	bolhas.visible = false
