class_name Bau
extends ObjetoBase

signal abertura_solicitada(bau: Bau)

var inventario_bau: Inventario
var _interacao: ComportamentoInterativo


func _ready() -> void:
	super._ready()

	# Cada instância do baú terá seu próprio inventário.
	inventario_bau = Inventario.new(18)

	_interacao = obter_comportamento(ComportamentoInterativo) as ComportamentoInterativo

	if _interacao == null:
		push_error("O baú precisa de ComportamentoInterativo.")
		return
	
	add_to_group("Baus")
	
	_interacao.interagiu.connect(_ao_interagir)


func _ao_interagir() -> void:
	print("Interagiu com o baú: ", name)
	abertura_solicitada.emit(self)
