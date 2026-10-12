extends RefCounted
## Registra objetos da cena original e recria apenas os objetos surgidos na partida.
## Canteiros cuidam dos próprios filhos para não duplicar a colheita.
var _mundo: Node2D
var _originais: Dictionary = {}

func configurar(mundo: Node2D) -> void:
	_mundo = mundo
	for no in _listar(mundo):
		var id = str(mundo.get_path_to(no))
		no.set_meta("id_save", id)
		_originais[id] = true

func _listar(pai: Node) -> Array[Node]:
	var resultado: Array[Node] = []
	for no in pai.get_children():
		if no.has_method("obter_estado_plantio") or no is ObjetoBase or no is ObjetoColetavel or no is ObjetoInterativo or no is Robo or no is BaseAnimal or no.name == "Copo" or ("estoque" in no and no.estoque is EstoqueTroca):
			resultado.append(no)
		else:
			resultado.append_array(_listar(no))
	return resultado

func _em_coleta(no: Node) -> bool:
	if no is ObjetoColetavel:
		return no._interacao_em_execucao
	if no is ObjetoBase:
		var coleta = no.obter_comportamento(ComportamentoColetavel)
		return coleta != null and coleta._interacao_em_execucao
	return false

func obter_dados() -> Dictionary:
	var objetos: Array = []
	var presentes: Dictionary = {}
	for no in _listar(_mundo):
		# O item já entrou no inventário, mesmo que a animação ainda esteja tocando.
		if no.is_queued_for_deletion() or _em_coleta(no):
			continue
		var id: String = no.get_meta("id_save", "")
		if not id.is_empty():
			presentes[id] = true
		var dados = {
			"id": id, "cena": no.scene_file_path,
			"pai": str(_mundo.get_path_to(no.get_parent())),
			"nome": str(no.name), "posicao": no.position,
			"terreno": no.get_meta("terreno", ""),
			"visivel": no.visible, "processamento": no.process_mode
		}
		if no.has_method("obter_estado_plantio"):
			dados["plantio"] = no.obter_estado_plantio()
		if no.has_method("obter_estado_alimentacao"):
			dados["alimentacao"] = no.obter_estado_alimentacao()
		if no is ObjetoColetavel:
			dados["item"] = no.item
		if no is ObjetoBase:
			var coleta = no.obter_comportamento(ComportamentoColetavel)
			if coleta:
				dados["item"] = coleta.item
				dados["coleta_ativa"] = coleta._detecao_ativa
		if no is Robo:
			dados["estado_robo"] = no._estado_atual
		if no is BaseAnimal:
			dados["animal"] = {
				"estado": no._estado_atual, "direcao": no._vetor_direcao,
				"animacao": no._direcao_animacao, "velocidade": no.velocidade_movimento,
				"tempo": no.timer.time_left
			}
		if "estoque" in no and no.estoque is EstoqueTroca:
			var estoque: Array = []
			for item in no.estoque.itens_a_venda:
				estoque.append({"item": item, "quantidade": no.estoque.obter_quantidade(item)})
			dados["estoque"] = estoque
		objetos.append(dados)
	var removidos: Array = []
	for id in _originais:
		if not presentes.has(id):
			removidos.append(id)
	return {"objetos": objetos, "removidos": removidos}

func restaurar(dados: Dictionary) -> void:
	for id in dados.get("removidos", []):
		var no = _mundo.get_node_or_null(NodePath(id))
		if no:
			no.get_parent().remove_child(no)
			no.queue_free()
	for estado in dados.get("objetos", []):
		var id: String = estado.get("id", "")
		var no = _mundo.get_node_or_null(NodePath(id)) if not id.is_empty() else null
		if no == null:
			var caminho: String = estado.get("cena", "")
			if caminho.is_empty() or not ResourceLoader.exists(caminho):
				push_warning("Cena do save não encontrada: " + caminho)
				continue
			var cena = load(caminho) as PackedScene
			var pai = _mundo.get_node_or_null(NodePath(estado.get("pai", ".")))
			if cena == null or pai == null:
				push_warning("Não foi possível restaurar: " + caminho)
				continue
			no = cena.instantiate()
			no.name = estado.get("nome", no.name)
			no.position = estado.get("posicao", Vector2.ZERO)
			if not id.is_empty():
				no.set_meta("id_save", id)
			pai.add_child(no)
		if not estado.get("terreno", "").is_empty():
			no.set_meta("terreno", estado["terreno"])
		no.position = estado.get("posicao", no.position)
		no.visible = estado.get("visivel", true)
		no.process_mode = estado.get("processamento", Node.PROCESS_MODE_INHERIT)
		if no.has_method("restaurar_estado_plantio"):
			no.restaurar_estado_plantio(estado.get("plantio", {}))
		if no is ObjetoColetavel:
			no.item = estado.get("item", no.item)
		if no is ObjetoBase:
			var coleta = no.obter_comportamento(ComportamentoColetavel)
			if coleta:
				coleta.item = estado.get("item", coleta.item)
				if estado.get("coleta_ativa", false):
					coleta.ativar_coleta(no)
				else:
					coleta.desativar_coleta()
		if no is Robo:
			no._estado_atual = estado.get("estado_robo", Robo.Estados.PARADO)
			no._atualizar_texto_instrucao()
		if no is BaseAnimal and estado.has("animal"):
			var animal: Dictionary = estado["animal"]
			no._estado_atual = animal["estado"]
			no._vetor_direcao = animal["direcao"]
			no._direcao_animacao = animal["animacao"]
			no.velocidade_movimento = animal["velocidade"]
			no.timer.start(maxf(0.01, animal["tempo"]))
		if no.has_method("restaurar_estado_alimentacao"):
			no.restaurar_estado_alimentacao(estado.get("alimentacao", {}))
		if "estoque" in no and no.estoque is EstoqueTroca:
			for entrada in estado.get("estoque", []):
				var item = entrada.get("item") as Item
				if no.estoque.comercializa(item):
					no.estoque.quantidades[item] = maxi(0, entrada.get("quantidade", 0))
