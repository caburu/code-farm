class_name ComportamentoColetavel
extends ComportamentoObjeto

@export var item: Item
@export var texto_interacao: String = "[C] para coletar"
@export var ativo_ao_iniciar: bool = true

var _label: Label
var _jogador_dentro: bool = false
var _interacao_em_execucao: bool = false
var _detecao_ativa: bool = true

func nome_grupo() -> String:
	return "ObjetosColetaveis"

func inicializar(objeto: ObjetoBase) -> void:
	_label = objeto.criar_label_interacao()
	_label.text = texto_interacao
	_detecao_ativa = ativo_ao_iniciar

func processar(objeto: ObjetoBase, _delta: float) -> void:
	if _detecao_ativa and _jogador_dentro and Input.is_action_just_pressed("coletar_item") and not _interacao_em_execucao:
		_interacao_em_execucao = true

		if item != null and Global.inventario.adicionar_item(item):
			_label.hide()
			
			if objeto.animador != null and objeto.animador.has_animation("coletar"):
				objeto.animador.play("coletar")
				await objeto.animador.animation_finished
			
			# Remove o objeto do mundo 
			objeto.queue_free()
		else:
			print("Inventário cheio ou item nulo!")
			_interacao_em_execucao = false

func ao_detectar_entrada(objeto: ObjetoBase, corpo: Node2D) -> void:
	if _detecao_ativa and corpo.is_in_group("Jogador"):
		_label.show()
		_jogador_dentro = true
		objeto.animador.play("destacar_objeto")

func ao_detectar_saida(objeto: ObjetoBase, corpo: Node2D) -> void:
	if _detecao_ativa and corpo.is_in_group("Jogador"):
		_label.hide()
		_jogador_dentro = false
		objeto.animador.play("RESET")

func ativar_coleta(objeto: ObjetoBase = null) -> void:
	_detecao_ativa = true
	
	# verifica se o jogador já está dentro da área
	if objeto != null and _label != null:
		var area = objeto.get_node_or_null("AreaDetecao") as Area2D
		if area:
			for corpo in area.get_overlapping_bodies():
				if corpo.is_in_group("Jogador"):
					_jogador_dentro = true
					_label.show()
					objeto.animador.play("destacar_objeto")
					break

func desativar_coleta() -> void:
	_detecao_ativa = false
	if _label:
		_label.hide()
		
