extends RoteiroMissao

func executar() -> void:
	# 1. Encontra o diário no mapa e faz ele "sumir" da tela
	var diario = mundo_jogo.obter_elemento("Missao0")
	if diario:
		diario.hide()
		diario.process_mode = PROCESS_MODE_DISABLED # Desativa a colisão
	
	# Recado do avô antes da leitura do diário.
	configurar_personagem(Global.nome_avo, Global.foto_avo)
	await dialogo("'Deixei um robô para te ajudar a cuidar da fazenda. Junto da caixa dele, guardei uma bolsa com 50 moedas.'")
	await dialogo("'Use essas moedas com cuidado, meu neto. Elas vão te ajudar a comprar as primeiras sementes e recomeçar.'")

	# 2. Emite o sinal para abrir o glossário direto na tela do jogador
	Global.emit_signal("abrir_glossario")
	
	# 3. Pausa o roteiro da missão e espera o jogador ler tudo e fechar o livro
	_pausar_missao()
	await aguardar_retomar() 
	
	# Isso vai fazer a missão virar 1, salvar o jogo 
	concluir_missao()
