extends RoteiroMissao


func executar() -> void:
	configurar_personagem(Global.nome_jogador ,Global.foto_jogador)
	await dialogo("Deve ser esse projeto que meu avó estava falando, tem um bilhete na caixa!")
	configurar_personagem(Global.nome_jogador ,Global.foto_jogador)
	await dialogo("Projeto AGR.O, robô de fazenda semiautomático, aceita comandos em python. Aperte o botão verte para inicia-lo")
	configurar_personagem(Global.nome_jogador ,Global.foto_jogador)
	await dialogo("Caraca que interessante! Será que ainda funciona?")
	configurar_personagem(Global.nome_robo ,Global.foto_robo)
	await dialogo("...")
	await dialogo("Iniciando Sistema Operacional AGR.O v1.0...")
	await dialogo("Olá, mundo! Inicialização concluída.")
	await dialogo("Para estabelecer privilégios de administrador e me dar ordens, preciso registrar sua identidade no meu banco de dados.")
	await dialogo("Como sou um modelo programável, você deve se comunicar comigo usando a linguagem Python.")
	await dialogo("Para me dizer o seu nome, use a função de saída padrão: o comando print(). Basta colocar o texto que você deseja exibir entre aspas, dentro dos parênteses. Veja o exemplo: print(\"Seu Nome\") ")
	await dialogo("Por favor, digite o comando com o seu nome agora para concluir o registro inicial.")

	
	var sucesso_nome = false
	while not sucesso_nome:
		var resultado = await obter_codigo_analisado()
		if resultado.status == ResultadoAPI.Status.SUCESSO:
			Global.nome_jogador = resultado.dados.get("nome_fazenda", "Jogador")
			await dialogo("Nome '" + Global.nome_jogador + "' processado com sucesso!")
			sucesso_nome = true
		else:
			for mensagem in resultado.mensagens:
				await dialogo(mensagem)

	
	await dialogo("Agora que você está registrado " + Global.nome_jogador + ", pode me pedir para realizar tarefas! Apenas diga o que fazer.")
	configurar_personagem(Global.nome_jogador ,Global.foto_jogador)
	await dialogo("Humm, o que será que posso pedir pra ele?")
	await dialogo("já sei! Preciso colocar um novo nome para a fazenda, vou atualizar a placa que está na porta de casa!")
	
	interface_jogo.exibir_interface(interface_jogo.Interface.PADRAO)
	mundo_jogo.obter_jogador().ativar_movimento()
	limpar_editor_codigo()
	
	var placa = mundo_jogo.obter_elemento("Missao1-Placa")
	
	placa.ativar_interacao()

	await placa.interagiu
	
	mundo_jogo.obter_jogador().desativar_movimento()
	interface_jogo.exibir_interface(interface_jogo.Interface.MISSAO)
	
	placa.desativar_interacao()

	await dialogo("Essa é a placa!")
	configurar_personagem(Global.nome_robo ,Global.foto_robo)
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
	
	
	interface_jogo.exibir_interface(interface_jogo.Interface.PADRAO)
	mundo_jogo.obter_jogador().ativar_movimento()
	concluir_missao()

func _tocar_animacao_placa(objeto_alvo: Object, nome_fazenda: String) -> void:
	var posicao_tela = objeto_alvo.get_global_transform_with_canvas().origin
	var texto_placa = preload("res://mundo_jogo/animacoes/texto_placa/texto_placa.tscn").instantiate()
	
	mundo_jogo.adicionar_elemento_canvas(texto_placa)
	texto_placa.exibir(nome_fazenda, posicao_tela)
	
	await mundo_jogo.get_tree().create_timer(5).timeout
	
	texto_placa.esconder()
	texto_placa.queue_free()
