class_name GerenciadorNPCs
extends Node

var mundo_jogo: MundoJogo
var interface_jogo: InterfaceJogo
var interface_npc: InterfaceNPC
var npc: Node

func configurar(mundo_jogo_ref: MundoJogo, interface_jogo_ref: InterfaceJogo) -> void:
	mundo_jogo = mundo_jogo_ref
	interface_jogo = interface_jogo_ref
	interface_npc = interface_jogo.obter_interface(interface_jogo.Interface.DIALOGO_NPC)
	
	Global.conectar_sinal(Global, "iniciar_dialogo_npc", Callable(self, "_ao_iniciar_dialogo"))

func _ao_iniciar_dialogo(_npc: Node) -> void:
	npc = _npc
	if not npc.dados_dialogo:
		print("Erro: Este NPC não tem um arquivo de DadosDialogo configurado!")
		return
		
	# Trava o jogador
	var jogador = mundo_jogo.obter_jogador()
	jogador.desativar_movimento()
	
	# Mostra a UI e passa as informações do NPC
	interface_jogo.exibir_interface(interface_jogo.Interface.DIALOGO_NPC)
	interface_npc.atualizar_personagem(npc.nome, npc.foto)
	
	# Executa a leitura do Roteiro
	await _tocar_roteiro(npc.dados_dialogo)
	
	# Libera o jogador quando acabar
	interface_jogo.exibir_interface(interface_jogo.Interface.PADRAO)
	jogador.ativar_movimento()
	# Reativa o trigger do NPC para podermos falar com ele de novo
	npc.area_interacao.ativar_interacao()

func _tocar_roteiro(dados: DadosDialogo) -> void:
	# Lê as falas normais uma a uma
	for fala in dados.falas:
		await interface_npc.exibir_dialogo(fala)
		
	if dados.tem_escolhas and dados.opcoes.size() > 0:
		var indice_escolhido = await interface_npc.exibir_dialogo_com_escolhas(dados.pergunta, dados.opcoes)
		
		#Pega a ação especial se tiver
		var acao = ""
		if dados.acoes.size() > indice_escolhido and dados.acoes[indice_escolhido] != null:
			acao = dados.acoes[indice_escolhido]
			
		if acao == "abrir_loja":
			interface_npc.abrir_painel_troca(npc.estoque)
			
			await Global.missao_fechada
		
		# Se tiver um arquivo .tres linkado nessa opção, toca ele em seguida
		if dados.proximas_rotas.size() > indice_escolhido and dados.proximas_rotas[indice_escolhido] != null:
			await _tocar_roteiro(dados.proximas_rotas[indice_escolhido])
	
