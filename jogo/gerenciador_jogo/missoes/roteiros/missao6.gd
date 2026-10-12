extends RoteiroMissao

func executar() -> void:
	await dialogo("Ótimo trabalho cuidando das plantações! Agora chegou a hora de alimentar os animais da fazenda.")
	await dialogo("Cada um deles tem uma comida favorita, então vamos ter que escolher com cuidado o que dar pra cada um.")
	await dialogo("Pra isso, a gente vai usar uma estrutura chamada if. Ela serve pra tomar decisões no seu código.")
	await dialogo("Funciona assim: você testa uma condição e, se for verdadeira, executa um trecho de código.")
	await dialogo("Mas e se tiver mais de uma possibilidade? Aí usamos o elif, que significa else if.")
	await dialogo("E no final, se nenhuma das opções anteriores for verdadeira, usamos o else. Ele cobre todos os outros casos.")
	
	await dialogo("Olha só esse exemplo:")

	await codigo('''animal = "coelho"
if animal == "cachorro":
	print("Dar ração")
elif animal == "coelho":
	print("Dar cenoura")
else:
	print("Esse animal não vai comer agora")
''')

	await dialogo("Assim, dependendo da comida que está na variável, a gente decide pra quem dar.")

	await dialogo("Vamos colocar isso em prática?")
	await dialogo("Hmm... espera aí... o baú das comidas está vazio?!")
	await dialogo("Alguém deve ter mexido aqui... Sem as comidas, não tem como alimentar os animais.")
	await dialogo("Você pode procurar por aí e recolher as comidas primeiro? Elas devem estar espalhadas perto do celeiro.")
	await dialogo("Assim que você encontrar todas elas, volte e interaja comigo de novo!")

	# Esconde interface e libera o jogador
	var jogador = mundo_jogo.obter_jogador()
	jogador.ativar_movimento()
	_interface_missao.visible = false

	# Espera o jogador coletar os itens
	await aguardar_condicao(func():
		return Global.inventario.tem_itens(["Comida Vaca", "Comida Galinha", "Comida Porco"])
	)

	# Espera o jogador interagir de novo com o objeto
	await aguardar_reinteracao()

	# Retoma a missão normalmente
	jogador.desativar_movimento()
	_interface_missao.visible = true

	await dialogo("Ah, agora sim! Com as comidas no inventário, conseguimos alimentar os animais.")
	await dialogo("Vamos fazer o seguinte: use uma variável chamada 'comida' com if, elif e else para alimentar cada animal com sua comida favorita")
	await dialogo("Você pode usar um comando print() que descreva essa ação, indicando qual animal está sendo alimentado.")

	await dialogo("Aqui vai uma ajudinha:
	- Galinha gosta de 'milho'
	- Vaca prefere 'feno'
	- Porco come qualquer outra coisa!
	")

	await dialogo("Lembre-se de usar o print() para mostrar qual animal está sendo alimentado.")

	var sucesso = false
	while not sucesso:
		var resultado = await obter_codigo_analisado()

		if resultado.status == ResultadoAPI.Status.SUCESSO:
			await dialogo("Excelente! Cada animal recebeu a comida certa! Parabéns, você está ficando fera em programar e cuidar da sua fazenda. Continue explorando sua fazenda em busca de novos desafios")
			sucesso = true
			Global.inventario.remover_itens(["Comida Vaca", "Comida Galinha", "Comida Porco"])

		else:
			for mensagem in resultado.mensagens:
				await dialogo(mensagem)

	concluir_missao()

# Espera enquanto a condição não for verdadeira
func aguardar_condicao(condicao: Callable) -> void:
	while not condicao.call():
		await mundo_jogo.get_tree().process_frame

# Espera o jogador interagir novamente com o objeto da missão atual
func aguardar_reinteracao() -> void:
	var objeto = mundo_jogo.obter_elemento("Missao%d" % Global.missao_atual)
	Global.retomando_missao = true
	objeto.ativar_interacao()
	await objeto.interagiu
	objeto.desativar_interacao()
	Global.retomando_missao = false
