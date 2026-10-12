class_name Bancada
extends ObjetoBase

signal abertura_solicitada(bancada: Bancada)

@export var bau: Bau
@export_range(0, 5, 1) var id_canteiro: int = 0
@export var registro_plantio: RegistroPlantio

var codigo_digitado: String = ""
var _interacao: ComportamentoInterativo


func _ready() -> void:
	super._ready()

	_interacao = obter_comportamento(
		ComportamentoInterativo
	) as ComportamentoInterativo

	if _interacao == null:
		push_error("A bancada precisa de ComportamentoInterativo.")
		return

	add_to_group("Bancadas")
	_interacao.interagiu.connect(_ao_interagir)


func _ao_interagir() -> void:
	abertura_solicitada.emit(self)


func liberar_interacao() -> void:
	if _interacao != null:
		_interacao.liberar_interacao()
		
func executar_acoes(acoes: Array) -> String:
	if not is_instance_valid(registro_plantio):
		return "Esta bancada não tem um registro de plantio associado."

	if not is_instance_valid(bau):
		return "Esta bancada não tem um baú associado."

	if acoes.is_empty():
		return "Nenhuma ação recebida."

	var concluidas: int = 0

	for valor in acoes:
		if not valor is Dictionary:
			return "A API devolveu uma ação inválida."

		var acao: Dictionary = valor
		var tipo: String = str(acao.get("tipo", ""))
		var linha: int = int(acao.get("linha", -1))
		var coluna: int = int(acao.get("coluna", -1))
		var linha_codigo: int = int(acao.get("linha_codigo", 0))

		var espaco := registro_plantio.obter_espaco(
			id_canteiro, linha, coluna
		) as AreaPlantio

		var erro: String = ""

		if espaco == null:
			erro = "Esse espaço não existe no canteiro."
		else:
			match tipo:
				"plantar":
					var cultura: String = str(acao.get("cultura", ""))
					var semente := _buscar_semente(cultura)

					if semente == null:
						erro = "Não há sementes de %s no baú." % cultura
					else:
						erro = espaco.plantar_semente(
							semente, bau.inventario_bau
						)

				"regar":
					erro = espaco.regar_por_codigo()

				"colher":
					erro = espaco.colher_por_codigo(
						bau.inventario_bau
					)

				_:
					erro = "Ação desconhecida: %s." % tipo

		if not erro.is_empty():
			return (
				"Linha %d: %s\nAções concluídas antes do erro: %d."
				% [linha_codigo, erro, concluidas]
			)

		concluidas += 1

	return "Execução concluída! Ações realizadas: %d." % concluidas


func _buscar_semente(cultura: String) -> Item:
	for pilha in bau.inventario_bau.slots:
		if pilha.item == null or pilha.quantidade <= 0:
			continue

		if (
			pilha.item.tipo == "semente"
			and pilha.item.nome == "semente_" + cultura
		):
			return pilha.item

	return null
