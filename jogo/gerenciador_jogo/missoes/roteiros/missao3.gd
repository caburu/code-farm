extends RoteiroMissao

var _etapa_atual: int = 1

func executar() -> void:
	await parte1()
	_etapa_atual += 1
	await parte2()
	concluir_missao()

func parte1() -> void:
	limpar_editor_codigo()
	
	await dialogo("Ótimo trabalho no seu primeiro código! Agora precisamos planejar melhor o que vamos fazer.")
	await dialogo("Programadores costumam usar algo chamado comentários para fazer anotações no código.")
	await dialogo("Comentários de uma linha começam com o símbolo # e ajudam a documentar o que o código faz. Diferente do comando print(), o texto que você colocar em um comentário será ignorado pelo programa, servindo apenas para organizar e explicar partes do código.")
	await dialogo("Por exemplo, se você quiser anotar suas tarefas do dia, poderia usar o símbolo # antes de cada nota. Veja só:")
	await codigo("# Lista de tarefas do dia
# 1. Organizar a sala
# 2. Plantar sementes no quintal
	")
	await dialogo("Agora é sua vez! Use comentários de uma linha para listar 3 tarefas que você precisa fazer na casa nova. Pode ser algo como '1. Limpar a cozinha', '2. Comprar móveis', etc!")

	var sucesso = false
	while not sucesso:
		var resultado = await obter_codigo_analisado()
		
		if resultado.status == ResultadoAPI.Status.SUCESSO:
			await dialogo("Muito bem! Agora vamos aprender um pouco mais sobre comentários!")
			sucesso = true
		else:
			for mensagem in resultado.mensagens:
				await dialogo(mensagem)

func parte2() -> void:
	limpar_editor_codigo()
	
	await dialogo("Ótimo! Agora que você já sabe comentar uma linha, vamos aprender a comentar várias linhas de uma vez.")
	await dialogo('Em Python, você pode usar três aspas duplas """ para criar comentários que ocupam várias linhas, no inicio e no final do texto que queremos comentar.')
	await dialogo("Isso é útil para descrições mais longas ou para desativar trechos inteiros de código temporariamente.")
	await dialogo("Por exemplo, você pode descrever todo o propósito do seu código assim:")
	await codigo('""" 
Este código organiza as tarefas da casa nova. É importante manter tudo bem documentado para não esquecer nada! 
"""
')
	await dialogo("Experimente adicionar um comentário de várias linhas no início do seu código, explicando o que ele faz e por que ele é útil para você!")

	var sucesso = false	
	while not sucesso:
		var resultado = await obter_codigo_analisado()
		
		if resultado.status == ResultadoAPI.Status.SUCESSO:
			await dialogo("Muito bem! Agora sua lista de tarefas ficou fenomenal!")
			await dialogo("Agora vamos aproveitar o embalo e arrumar a bagunça no resto da casa.")
			sucesso = true
		else:
			for mensagem in resultado.mensagens:
				await dialogo(mensagem)

func contexto():
	var chave = "parte" + str(_etapa_atual)
	return {"etapa": chave}
