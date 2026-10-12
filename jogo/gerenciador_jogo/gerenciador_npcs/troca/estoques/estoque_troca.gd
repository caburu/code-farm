class_name EstoqueTroca
extends Resource

@export var itens_a_venda: Array[Item] = []
@export var quantidades: Dictionary[Item, int] = {}
# Limite zero significa que o NPC pode receber qualquer quantidade desse item.
@export var limites: Dictionary[Item, int] = {}

func comercializa(item: Item) -> bool:
	return item != null and item in itens_a_venda

func obter_quantidade(item: Item) -> int:
	if not comercializa(item):
		return 0
	return maxi(0, quantidades.get(item, 0))

func pode_receber(item: Item) -> bool:
	if not comercializa(item):
		return false
	var limite: int = maxi(0, limites.get(item, 0))
	return limite == 0 or obter_quantidade(item) < limite

func retirar(item: Item) -> bool:
	var quantidade := obter_quantidade(item)
	if quantidade <= 0:
		return false
	quantidades[item] = quantidade - 1
	return true

func adicionar(item: Item) -> bool:
	if not pode_receber(item):
		return false
	quantidades[item] = obter_quantidade(item) + 1
	return true
