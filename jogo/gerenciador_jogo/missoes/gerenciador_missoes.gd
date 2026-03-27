class_name GerenciadorMissoes 

extends Node

var mundo_jogo: MundoJogo
var interface_jogo: InterfaceJogo

var _objeto_missao_atual: ObjetoInterativo = null

var _roteiro_missao_atual: RoteiroMissao = null

func configurar(mundo_jogo: MundoJogo, interface_jogo: InterfaceJogo):
	self.mundo_jogo = mundo_jogo
	self.interface_jogo = interface_jogo
	
	Global.conectar_sinal(Global, "missao_fechada", Callable(self, "_ao_fechar_missao"))

func executar():
	_ativar_objeto_missao_atual()

func _ativar_objeto_missao_atual() -> void:
	if _objeto_missao_atual:
		_objeto_missao_atual.desativar_interacao()
	
	if not Global.concluiu_todas_missoes():
		var nome_objeto = "Missao%d" % Global.missao_atual

		_objeto_missao_atual = mundo_jogo.obter_elemento(nome_objeto)
		_objeto_missao_atual.ativar_interacao()
	
		Global.conectar_sinal(_objeto_missao_atual, "interagiu", Callable(self, "_ao_interagir_objeto"))
	else:
		print("Parabéns! Você concluiu todas as missões!")

func _ao_interagir_objeto() -> void:
	if Global.retomando_missao:
		return

	interface_jogo.exibir_interface(interface_jogo.Interface.MISSAO)

	var jogador = mundo_jogo.obter_jogador()
	jogador.desativar_movimento()
	_executar_missao_atual()

func _executar_missao_atual() -> void:
	_objeto_missao_atual.desativar_interacao()
	
	var caminho_missao = "res://gerenciador_jogo/missoes/roteiros/missao%d.gd" % Global.missao_atual
	_roteiro_missao_atual = load(caminho_missao).new()
	_roteiro_missao_atual.configurar(mundo_jogo, interface_jogo)

	Global.conectar_sinal(Global, "missao_concluida", Callable(self, "_concluir_missao_atual"))

	_roteiro_missao_atual.executar()
	
func _concluir_missao_atual() -> void:
	Global.missao_atual += 1
	print("Missao %d concluida!" % Global.missao_atual)
	
	var jogador = mundo_jogo.obter_jogador()
	Global.salvar_jogo(0, jogador.global_position)
	
	_ativar_objeto_missao_atual()
	
	interface_jogo.exibir_interface(interface_jogo.Interface.PADRAO)
	
	jogador.ativar_movimento()

func _ao_fechar_missao():
	_objeto_missao_atual.ativar_interacao()
	_roteiro_missao_atual.queue_free()
