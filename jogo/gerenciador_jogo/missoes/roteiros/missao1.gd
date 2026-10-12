extends RoteiroMissao

const CENA_ROBO = preload("res://mundo_jogo/npcs/robo.tscn")


func executar() -> void:
	var etapa: int = Global.progresso_missoes.get("missao1", 0)
	if etapa < 1:
		await _introducao()
		Global.progresso_missoes["missao1"] = 1
	if etapa < 2:
		await _coletar_caixa()
		Global.progresso_missoes["missao1"] = 2
	if etapa < 3:
		await _abrir_caixa()
	await _configurar_robo()

func _introducao() -> void:
	# -------------------------------------------------------------------------
	# FASE 1: DIÁLOGO INICIAL AO INTERAGIR DIRETO COM A CAIXA
	# -------------------------------------------------------------------------
	configurar_personagem(Global.nome_jogador, Global.foto_jogador)
	await dialogo("Esta é a caixa que meu avô deixou... Tem uma instrução gravada nela.")
	
	configurar_personagem(Global.nome_avo, Global.foto_avo)
	await dialogo("'Querido neto, se você está vendo isso, o mundo mudou. Deixei meu maior projeto nesta caixa.'")
	await dialogo("'Não a abra aqui dentro. Leve a caixa para o terreno da fazenda lá fora e coloque-a no chão.'")
	await dialogo("Ela contém um robô para te auxiliar. Você poderá chamá-lo com a tecla R quando precisar.")

	configurar_personagem(Global.nome_jogador, Global.foto_jogador)
	await dialogo("Tem uma bolsa junto da caixa! São as moedas que meu avô deixou para mim.")
	await dialogo("50 moedas! Vou guardá-las para comprar sementes e começar a cuidar da fazenda.")
	Global.moedas_descobertas = true

func _coletar_caixa() -> void:

	
	# -------------------------------------------------------------------------
	# FASE 2: LIBERAR A COLETA DA CAIXA NO BUNKER
	# -------------------------------------------------------------------------
	var objeto_caixa = mundo_jogo.obter_elemento("Missao1")
	
	if objeto_caixa and is_instance_valid(objeto_caixa):
		var comp_interativo = objeto_caixa.obter_comportamento(ComportamentoInterativo)
		if comp_interativo:
			comp_interativo.desativar_interacao()

		var comp_coletavel = objeto_caixa.obter_comportamento(ComportamentoColetavel)
		if comp_coletavel:
			comp_coletavel.ativar_coleta(objeto_caixa)

	if not Global.inventario.tem_itens(["caixa_robo"]):
		configurar_personagem(Global.nome_jogador, Global.foto_jogador)
		await dialogo("Certo, preciso coletar esta caixa e levá-la para fora.")
		
		interface_jogo.exibir_interface(interface_jogo.Interface.PADRAO)
		mundo_jogo.obter_jogador().ativar_movimento()
		
		# Aguarda o jogador pegar a caixa
		if objeto_caixa and is_instance_valid(objeto_caixa):
			await objeto_caixa.tree_exited
			
		mundo_jogo.obter_jogador().desativar_movimento()
		interface_jogo.exibir_interface(interface_jogo.Interface.MISSAO)
		await mundo_jogo.get_tree().create_timer(0.1).timeout
		
		configurar_personagem(Global.nome_jogador, Global.foto_jogador)
		await dialogo("Peguei a caixa. Agora vou levá-la para o Terreno da Fazenda.")
	
	interface_jogo.exibir_interface(interface_jogo.Interface.PADRAO)
	mundo_jogo.obter_jogador().ativar_movimento()
	
	# -------------------------------------------------------------------------
	# FASE 3: MONITORAR A CAIXA NO MUNDO E VERIFICAR O LOCAL
	# -------------------------------------------------------------------------
func _abrir_caixa() -> void:
	interface_jogo.exibir_interface(interface_jogo.Interface.PADRAO)
	mundo_jogo.obter_jogador().ativar_movimento()
	var caixa_dropada: Node2D = null
	
	while true:
		await mundo_jogo.get_tree().create_timer(0.5).timeout
		var jogador = mundo_jogo.obter_jogador()
		
		var objetos_no_chao = mundo_jogo.get_tree().get_nodes_in_group("ObjetosColetaveis")
		var caixa_encontrada: Node2D = null
		
		for obj in objetos_no_chao:
			var comp_coletavel = obj.obter_comportamento(ComportamentoColetavel) if obj.has_method("obter_comportamento") else null
			if comp_coletavel and comp_coletavel.item and comp_coletavel.item.nome == "caixa_robo":
				caixa_encontrada = obj
				break
		
		if caixa_encontrada != null:

			var comp_coletavel = caixa_encontrada.obter_comportamento(ComportamentoColetavel)
			if comp_coletavel and not comp_coletavel._detecao_ativa:
				comp_coletavel.ativar_coleta(caixa_encontrada)

			var comp_interativo = caixa_encontrada.obter_comportamento(ComportamentoInterativo)
			if comp_interativo:
				if caixa_encontrada.get_meta("terreno", jogador.terreno_atual) == "TerrenoFazenda":

					caixa_dropada = caixa_encontrada
					break
				else:

					if comp_interativo.interagiu.is_connected(_ao_tentar_abrir_no_lugar_errado):
						pass
					else:
						comp_interativo.texto_interacao = "[E] para tentar abrir"
						comp_interativo.ativar_interacao(caixa_encontrada)
						comp_interativo.interagiu.connect(_ao_tentar_abrir_no_lugar_errado, CONNECT_ONE_SHOT)

	# -------------------------------------------------------------------------
	# FASE 4: CAIXA POSICIONADA NO TERRENO DA FAZENDA -> ABRIR A CAIXA
	# -------------------------------------------------------------------------
	var comp_coletavel_dropada = caixa_dropada.obter_comportamento(ComportamentoColetavel)
	if comp_coletavel_dropada:
		comp_coletavel_dropada.desativar_coleta()
	
	var comp_interativo_caixa = caixa_dropada.obter_comportamento(ComportamentoInterativo)
	if comp_interativo_caixa:
		if comp_interativo_caixa.interagiu.is_connected(_ao_tentar_abrir_no_lugar_errado):
			comp_interativo_caixa.interagiu.disconnect(_ao_tentar_abrir_no_lugar_errado)
			
		comp_interativo_caixa.texto_interacao = "[E] para abrir a caixa"
		comp_interativo_caixa.ativar_interacao(caixa_dropada)
		await comp_interativo_caixa.interagiu

	# -------------------------------------------------------------------------
	# FASE 5: TRANSFORMAÇÃO (CAIXA -> ROBÔ)
	# -------------------------------------------------------------------------
	mundo_jogo.obter_jogador().desativar_movimento()
	interface_jogo.exibir_interface(interface_jogo.Interface.MISSAO)
	await mundo_jogo.get_tree().create_timer(0.1).timeout

	configurar_personagem(Global.nome_jogador, Global.foto_jogador)
	await dialogo("Vou abrir a caixa aqui fora...")

	var posicao_spawn = caixa_dropada.global_position
	var pai_da_caixa = caixa_dropada.get_parent()
	
	caixa_dropada.queue_free()
	
	var robo_instanciado = CENA_ROBO.instantiate()
	robo_instanciado.global_position = posicao_spawn
	pai_da_caixa.add_child(robo_instanciado)
	Global.progresso_missoes["missao1"] = 3
	
	await mundo_jogo.get_tree().create_timer(1.0).timeout
	
	# -------------------------------------------------------------------------
	# FASE 6: DIÁLOGO COM O ROBÔ E CONFIGURAÇÃO DO NOME (PYTHON)
	# -------------------------------------------------------------------------
func _configurar_robo() -> void:
	mundo_jogo.obter_jogador().desativar_movimento()
	interface_jogo.exibir_interface(interface_jogo.Interface.MISSAO)
	configurar_personagem(Global.nome_robo, Global.foto_robo)
	await dialogo("Iniciando Sistema Operacional AGR.O v1.0...")
	await dialogo("Olá, mundo! Inicialização concluída fora do Bunker.")
	await dialogo("Para estabelecer privilégios de administrador, preciso registrar seu nome.")
	await dialogo("Use o comando: print(\"Seu Nome\") no editor de código.")
	
	var sucesso_nome = false
	while not sucesso_nome:
		var resultado = await obter_codigo_analisado()
		if resultado.status == ResultadoAPI.Status.SUCESSO:
			Global.nome_jogador = resultado.dados.get("nome_jogador", "Jogador")
			
			configurar_personagem(Global.nome_jogador, Global.foto_jogador)
			await dialogo("Pronto! Ele entendeu meu nome.")
			sucesso_nome = true
		else:
			for mensagem in resultado.mensagens:
				await dialogo(mensagem)
				
	configurar_personagem(Global.nome_robo, Global.foto_robo)
	await dialogo("Agora que estamos conectados, precisamos batizar esta propriedade.")
	await dialogo("Siga-me até a placa da fazenda na entrada para configurarmos o nome dela.")
	
	interface_jogo.exibir_interface(interface_jogo.Interface.PADRAO)
	mundo_jogo.obter_jogador().ativar_movimento()
	concluir_missao()
	

func _ao_tentar_abrir_no_lugar_errado() -> void:
	mundo_jogo.obter_jogador().desativar_movimento()
	interface_jogo.exibir_interface(interface_jogo.Interface.MISSAO)
	
	configurar_personagem(Global.nome_jogador, Global.foto_jogador)
	await dialogo("Não devo abrir a caixa aqui dentro. O avô disse para levá-la para o terreno da fazenda lá fora.")
	
	interface_jogo.exibir_interface(interface_jogo.Interface.PADRAO)
	mundo_jogo.obter_jogador().ativar_movimento()
