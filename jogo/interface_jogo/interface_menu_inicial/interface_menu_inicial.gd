class_name InterfaceMenuInicial 

extends Control

signal novo_jogo
signal continuar_jogo

@onready var painel_botoes = $VBoxContainer/PainelBotoes
@onready var painel_creditos = $VBoxContainer/PainelCreditos
@onready var fundo_texto_creditos = $VBoxContainer/PainelCreditos/VBoxContainer/FundoEditorTexto/MarginContainer/MarginContainer
@onready var texto_creditos = $VBoxContainer/PainelCreditos/VBoxContainer/FundoEditorTexto/MarginContainer/MarginContainer/RichTextLabel
@onready var botao_fechar_creditos = $VBoxContainer/PainelCreditos/VBoxContainer/BotaoFecharCreditos

var tween_creditos: Tween

func _ready():
	painel_creditos.visible = false
	fundo_texto_creditos.clip_contents = true
	
func _ao_clicar_novo_jogo():
	Global.emit_signal("novo_jogo")

func _ao_clicar_continuar_jogo():
	
	var slot_mais_recente = Global.obter_slot_mais_recente()
	
	if slot_mais_recente != -1:
		print("Continuando do slot mais recente: ", slot_mais_recente)
		
		
		Global.carregar_jogo(slot_mais_recente)
		
		Global.emit_signal("continuar_jogo")
		
	else:
		print("Nenhum save encontrado para continuar!")
		

func _ao_clicar_sair_jogo():
	get_tree().quit()

func _ao_clicar_creditos():
	painel_botoes.hide()
	painel_creditos.show()
	
	await get_tree().process_frame

	texto_creditos.scroll_active = false
	texto_creditos.size.y = texto_creditos.get_content_height()
	
	texto_creditos.position.y = fundo_texto_creditos.size.y
	
	var distancia = texto_creditos.size.y + fundo_texto_creditos.size.y
	var duracao = distancia / 25.0

	tween_creditos = create_tween()
	tween_creditos.set_trans(Tween.TRANS_LINEAR)

	tween_creditos.tween_property(
		texto_creditos,
		"position:y",
		-texto_creditos.size.y,
		duracao
	).set_delay(1)

	tween_creditos.finished.connect(_ao_terminar_creditos)

func _ao_terminar_creditos():
	if painel_creditos.visible:
		painel_creditos.hide()
		painel_botoes.show()

func _ao_clicar_fechar_creditos():
	if tween_creditos:
		tween_creditos.kill()
	painel_creditos.hide()
	painel_botoes.show()
