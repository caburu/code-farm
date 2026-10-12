class_name ComportamentoInterativo
extends ComportamentoObjeto

signal interagiu

@export var texto_interacao: String = "[E] para abrir":
	set(valor):
		texto_interacao = valor
		if is_instance_valid(_label):
			_label.text = valor
@export var ativo_ao_iniciar: bool = true

var _objeto: ObjetoBase
var _label: Label

var _detecao_ativa: bool = false
var _jogador_dentro: bool = false
var _interacao_em_execucao: bool = false


func nome_grupo() -> String:
	return "ObjetosInterativos"


func inicializar(objeto: ObjetoBase) -> void:
	_objeto = objeto
	_label = objeto.criar_label_interacao()
	_label.text = texto_interacao
	_label.hide()

	_detecao_ativa = ativo_ao_iniciar



func pode_interagir() -> bool:
	return (
		is_instance_valid(_objeto)
		and _detecao_ativa
		and _jogador_dentro
		and not _interacao_em_execucao
		and not interagiu.get_connections().is_empty()
	)


func definir_selecionado(selecionado: bool) -> void:
	if not is_instance_valid(_label):
		return

	_label.visible = selecionado and pode_interagir()

	if _label.visible:
		_tocar_animacao("destacar_objeto")
	else:
		_tocar_animacao("RESET")


func executar_interacao() -> void:
	if not pode_interagir():
		return

	_interacao_em_execucao = true
	definir_selecionado(false)
	interagiu.emit()


func ao_detectar_entrada(
	_objeto_ref: ObjetoBase,
	corpo: Node2D
) -> void:
	if corpo.is_in_group("Jogador"):
		_jogador_dentro = true

func ao_detectar_saida(
	_objeto_ref: ObjetoBase,
	corpo: Node2D
) -> void:
	if corpo.is_in_group("Jogador"):
		_jogador_dentro = false
		_interacao_em_execucao = false
		definir_selecionado(false)


func ativar_interacao(objeto: ObjetoBase = null) -> void:
	_detecao_ativa = true
	_interacao_em_execucao = false

	var alvo: ObjetoBase = objeto if objeto != null else _objeto

	if is_instance_valid(alvo):
		var area := alvo.get_node_or_null("AreaDetecao") as Area2D

		if area != null:
			_jogador_dentro = false

			for corpo in area.get_overlapping_bodies():
				if corpo.is_in_group("Jogador"):
					_jogador_dentro = true
					break


func desativar_interacao() -> void:
	_detecao_ativa = false
	definir_selecionado(false)


func liberar_interacao() -> void:
	_interacao_em_execucao = false


func _tocar_animacao(nome: String) -> void:
	if not is_instance_valid(_objeto):
		return

	if is_instance_valid(_objeto.animador):
		if _objeto.animador.has_animation(nome):
			_objeto.animador.play(nome)
