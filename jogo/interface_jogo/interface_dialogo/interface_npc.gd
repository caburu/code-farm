class_name InterfaceNPC

extends Control

@onready var _caixa_dialogo: Control = %CaixaDialogo
@onready var _painel_troca: PainelTroca = $PainelTroca
@onready var _botao_fechar: Control = $Fechar
@onready var _tooltip_confirmacao: CenterContainer = $TooltipConfirmacao
@onready var _mensagem: MensagemTroca = $Mensagem

var foto
var personagem

func _ready() -> void:
	_painel_troca.troca_recusada.connect(_ao_recusar_troca)
	_painel_troca.troca_concluida.connect(_mensagem.limpar)
	_painel_troca.visibility_changed.connect(_ao_mudar_visibilidade_loja)
	_tooltip_confirmacao.visibility_changed.connect(_ao_mudar_visibilidade_confirmacao)

func _ao_recusar_troca(motivo: PainelTroca.ErroTroca) -> void:
	match motivo:
		PainelTroca.ErroTroca.ESTOQUE_CHEIO:
			_mensagem.exibir("O vendedor não tem espaço para mais unidades deste item.")
		PainelTroca.ErroTroca.ESTOQUE_ESGOTADO:
			_mensagem.exibir("Este item está esgotado.")
		PainelTroca.ErroTroca.MOEDAS_INSUFICIENTES:
			_mensagem.exibir("Você não tem moedas suficientes.")
		PainelTroca.ErroTroca.INVENTARIO_CHEIO:
			_mensagem.exibir("Não há espaço no seu inventário.")
		PainelTroca.ErroTroca.ITEM_NAO_COMERCIALIZADO:
			_mensagem.exibir("Este vendedor não negocia esse item.")
		PainelTroca.ErroTroca.ITEM_INDISPONIVEL:
			_mensagem.exibir("Você não possui mais esse item.")

func _ao_mudar_visibilidade_loja() -> void:
	if not _painel_troca.is_visible_in_tree():
		_mensagem.limpar()

func _ao_mudar_visibilidade_confirmacao() -> void:
	if _tooltip_confirmacao.is_visible_in_tree():
		_mensagem.limpar()


func atualizar_personagem(novo_nome: String, caminho_foto: String) -> void:
	personagem = novo_nome
	foto = caminho_foto

func exibir_dialogo(texto: String) -> void: 
	_caixa_dialogo.show()
	await _caixa_dialogo.exibir_dialogo(texto, foto, personagem, _caixa_dialogo.TipoDeDialogo.DIALOGO)

func exibir_dialogo_com_escolhas(texto: String, escolhas: Array) -> int:
	return await _caixa_dialogo.exibir_dialogo_com_escolhas(texto, foto, personagem, escolhas)

func abrir_painel_troca(estoque_do_npc: EstoqueTroca) -> void:
	_mensagem.limpar()
	_caixa_dialogo.hide()
	_botao_fechar.global_position.x = 145
	_painel_troca.abrir(estoque_do_npc)

func _ao_clicar_fechar_dialogo() -> void:
	hide()
	
	_caixa_dialogo.parar_som()
	
	_caixa_dialogo._limpar_botoes()
	
	if _painel_troca:
		_painel_troca.hide()
		_botao_fechar.global_position.x = 0
	
	Global.emit_signal("fim_dialogo_npc")
