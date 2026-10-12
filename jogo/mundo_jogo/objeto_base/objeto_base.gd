class_name ObjetoBase
extends StaticBody2D

## Cena genérica: escolha em @export quais comportamentos (Resources)
## este objeto tem. Hoje: ComportamentoInterativo e/ou ComportamentoColetavel.
@export var comportamentos: Array[ComportamentoObjeto] = []

@onready var animador: AnimationPlayer = $Animador
@onready var sprite: Sprite2D = $Sprite
@onready var container_labels: VBoxContainer = $ContainerLabels

func _ready() -> void:
	# Resources são compartilhados por padrão entre instâncias que apontam
	# pro mesmo .tres — duplicamos aqui pra cada objeto ter seu próprio
	# estado (_jogador_dentro, etc.) isolado dos demais.
	for i in comportamentos.size():
		comportamentos[i] = comportamentos[i].duplicate()

	container_labels.global_position.y -= sprite.region_rect.size.y

	for comportamento in comportamentos:
		if comportamento.nome_grupo() != "":
			add_to_group(comportamento.nome_grupo())
		comportamento.inicializar(self)

func _process(delta: float) -> void:
	for comportamento in comportamentos:
		comportamento.processar(self, delta)

func _ao_detectar_entrada(corpo: Node2D) -> void:
	for comportamento in comportamentos:
		comportamento.ao_detectar_entrada(self, corpo)

func _ao_detectar_saida(corpo: Node2D) -> void:
	for comportamento in comportamentos:
		comportamento.ao_detectar_saida(self, corpo)


func criar_label_interacao() -> Label:
	var label := Label.new()
	label.visible = false
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_constant_override("shadow_outline_size", 4)
	label.add_theme_font_size_override("font_size", 7)
	container_labels.add_child(label)
	return label

func tocar_animacao(nome: String) -> void:
	animador.play(nome)

func obter_largura() -> float:
	if sprite.region_enabled:
		return sprite.region_rect.size.x
	elif sprite.texture:
		return sprite.texture.get_width()
	return 0.0
	
func obter_comportamento(tipo_classe) -> ComportamentoObjeto:
	for comp in comportamentos:
		if is_instance_of(comp, tipo_classe):
			return comp
	return null
