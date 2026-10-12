extends RoteiroMissao


func executar() -> void:
	var placa = mundo_jogo.obter_elemento("Missao2")

	mundo_jogo.obter_jogador().desativar_movimento()
	interface_jogo.exibir_interface(interface_jogo.Interface.MISSAO)

	configurar_personagem(Global.nome_robo, Global.foto_robo)
	await dialogo("Use a função print() para indicar o nome da fazenda.")

	var sucesso_fazenda = false

	while not sucesso_fazenda:
		var resultado = await obter_codigo_analisado()

		if resultado.status == ResultadoAPI.Status.SUCESSO:
			var nome_fazenda = resultado.dados.get("nome_fazenda", "Minha Fazenda")
			Global.nome_fazenda_atual = nome_fazenda

			await dialogo("Veja como ficou:")
			await _tocar_animacao_placa(placa, nome_fazenda)

			sucesso_fazenda = true
		else:
			for mensagem in resultado.mensagens:
				await dialogo(mensagem)
				
	configurar_personagem(Global.nome_robo, Global.foto_robo)
	await dialogo("%s, se quiser minha companhia, chegue perto de mim e aperte E para que eu siga você!" % Global.nome_jogador)
	await dialogo("Agora que nossa fazenda já tem um nome, %s, está na hora de plantar alguma coisa!" % Global.nome_jogador)
	
	concluir_missao()


func _tocar_animacao_placa(objeto_alvo: Node2D,nome_fazenda: String) -> void:
	var posicao_tela = objeto_alvo.get_global_transform_with_canvas().origin
	var texto_placa = preload(
		"res://mundo_jogo/animacoes/texto_placa/texto_placa.tscn"
	).instantiate()

	mundo_jogo.adicionar_elemento_canvas(texto_placa)
	texto_placa.exibir(nome_fazenda, posicao_tela)

	await mundo_jogo.get_tree().create_timer(5.0).timeout

	texto_placa.esconder()
	texto_placa.queue_free()
