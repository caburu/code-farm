class_name InterfaceMissao

extends Control

@onready var _caixa_dialogo: Control = %CaixaDialogo
@onready var _editor_codigo: Control = %EditorCodigo
@onready var _tooltip: Control = %Tooltip

var foto = "res://assets/imagens/Tiny Wonder Forest/characters/main character old/portrait female.png"
var personagem = "Thais"

func atualizar_personagem(novo_nome: String, caminho_foto: String) -> void:
	personagem = novo_nome
	foto = caminho_foto

func exibir_dialogo(texto: String) -> void: 
	await _caixa_dialogo.exibir_dialogo(texto, foto, personagem, _caixa_dialogo.TipoDeDialogo.DIALOGO)

func exibir_codigo(texto: String) -> void:
	await _caixa_dialogo.exibir_dialogo(texto, foto, personagem, _caixa_dialogo.TipoDeDialogo.CODIGO)

func limpar_editor_codigo() -> void:
	_editor_codigo.limpar()

func ativar_editor_codigo() -> void:
	_editor_codigo.ativar()

func desativar_editor_codigo() -> void:
	_editor_codigo.desativar()

func obter_codigo_digitado() -> String:
	return _editor_codigo.obter_codigo_digitado()

func obter_resultado_api() -> ResultadoAPI:
	return await _editor_codigo.obter_resultado_api() 

func _ao_passar_mouse_termo(meta: Variant):
	var termo = str(meta)
	if Global.glossario.possui_termo(termo):
		var dados = Global.glossario.obter_dados_termo(termo)
		_tooltip.exibir(dados["nome"], dados["descricao"], dados["exemplo"])

func _ao_tirar_mouse_termo(meta: Variant):
	var _termo = str(meta)
	_tooltip.esconder()

func _ao_clicar_fechar_missao():
	hide()
	
	_caixa_dialogo.parar_som()
	
	Global.emit_signal("missao_fechada")
