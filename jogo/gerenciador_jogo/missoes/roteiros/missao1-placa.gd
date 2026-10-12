extends RoteiroMissao

func executar() -> void:
	await dialogo("Bem-vindo à sua nova fazenda! Está empolgado para começar? Vamos começar a deixá-la com a sua cara.")
	await dialogo("Antes de mais nada, que tal escolher um nome para sua nova fazenda? Assim você pode marcar o início dessa jornada que começa com muita energia positiva!")
	await dialogo("Para isso, vamos usar um comando muito importante em Python chamado print(). Esse comando é usado para exibir mensagens na tela.")
	await dialogo("Basta colocar o texto que você deseja imprimir entre aspas dentro da função. Por exemplo, se eu quiser exibir 'Olá mundo do Code Farm!', eu usaria o seguinte código:")
	await codigo("print(\"Olá mundo do Code Farm!\")")
	await dialogo("Agora é sua vez! Escreva o nome da sua fazenda, para que você o veja sempre que chegar em casa. Algo como ‘Fazenda Code Farm' ou o que preferir!")
	
	var sucesso = false
	while not sucesso:
		var resultado = await obter_codigo_analisado()
		
		if resultado.status == ResultadoAPI.Status.SUCESSO:
			await dialogo("Muito bem! Agora veja o nome da sua fazenda na placa!")

			var nome = resultado.dados.get("nome_fazenda", "Minha Fazenda")
			
			Global.nome_fazenda_atual = nome
			await _tocar_animacao_placa(nome)

			await dialogo("Agora que você já identificou sua nova fazenda, que tal entrar em casa e explorar mais?")

			sucesso = true
		else:
			for mensagem in resultado.mensagens:
				await dialogo(mensagem)
	
	concluir_missao()
	
func _tocar_animacao_placa(nome_fazenda: String) -> void:
	var placa = mundo_jogo.obter_objeto_interativo_atual()

	var posicao_tela = placa.get_global_transform_with_canvas().origin

	var texto_placa = preload("res://mundo_jogo/animacoes/texto_placa/texto_placa.tscn").instantiate()
	mundo_jogo.adicionar_elemento_canvas(texto_placa)

	texto_placa.exibir(nome_fazenda, posicao_tela)

	await mundo_jogo.get_tree().create_timer(5).timeout

	texto_placa.esconder()
	texto_placa.queue_free()
