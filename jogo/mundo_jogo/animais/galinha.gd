extends BaseAnimal
## Uma porção de milho produz um ovo; outra refeição só começa após a postura.
@export_range(16.0, 512.0, 1.0) var raio_busca_cocho: float = 160.0
@export_range(12.0, 64.0, 1.0) var distancia_comer: float = 24.0
@export_range(0.1, 30.0, 0.1) var tempo_para_comer: float = 1.0
@export_range(0.1, 300.0, 0.1) var tempo_para_ovo: float = 5.0
@export_range(0.0, 300.0, 0.1) var intervalo_refeicoes: float = 3.0
@export var velocidade_ate_cocho: float = 32.0
@export var cena_ovo: PackedScene = preload("res://mundo_jogo/objeto_base/objetos_coletaveis/ovo.tscn")

var _cocho: Node2D
var _tempo_comendo: float = 0.0
var _tempo_ovo_restante: float = -1.0
var _tempo_fome_restante: float = 0.0
var _tempo_fuga_restante: float = 0.0

func _ready() -> void:
	super._ready()
	add_to_group("Galinhas")

func _physics_process(delta: float) -> void:
	_atualizar_postura(delta)
	_tempo_fome_restante = maxf(0.0, _tempo_fome_restante - delta)
	_tempo_fuga_restante = maxf(0.0, _tempo_fuga_restante - delta)
	# A galinha só se aproxima da comida quando o jogador se afasta.
	for corpo in area_detecao.get_overlapping_bodies():
		if corpo.is_in_group("Jogador"):
			if _tempo_fuga_restante <= 0.0:
				_reagir_ao_personagem(corpo)
			_tempo_fuga_restante = tempo_fugindo
			_vetor_direcao = (global_position - corpo.global_position).normalized()
	if _tempo_fuga_restante > 0.0:
		_cocho = null
		_tempo_comendo = 0.0
		_estado_atual = ESTADO.ANDAR
		velocidade_movimento = 96.0
		_controle()
		return

	if _tempo_ovo_restante >= 0.0 or _tempo_fome_restante > 0.0:
		_passear()
		return
	var destino = _buscar_cocho()
	if destino != _cocho:
		_tempo_comendo = 0.0
	_cocho = destino
	if not is_instance_valid(_cocho):
		_passear()
		return

	timer.stop()
	velocidade_movimento = velocidade_ate_cocho
	if global_position.distance_to(_cocho.global_position) > distancia_comer:
		_tempo_comendo = 0.0
		_estado_atual = ESTADO.ANDAR
		_vetor_direcao = global_position.direction_to(_cocho.global_position)
		_controle()
	else:
		velocity = Vector2.ZERO
		_vetor_direcao = Vector2.ZERO
		_estado_atual = ESTADO.PARAR
		_animar_personagem()
		_tempo_comendo += delta
		if _tempo_comendo >= tempo_para_comer:
			# Consumo atômico: duas galinhas não podem usar a última porção.
			if _cocho.consumir_porcao():
				_tempo_ovo_restante = tempo_para_ovo
			_tempo_comendo = 0.0
			_cocho = null

func _buscar_cocho() -> Node2D:
	var mais_proximo: Node2D = null
	var distancia_minima = raio_busca_cocho
	for candidato in get_tree().get_nodes_in_group("CochosGalinhas"):
		if candidato.get_parent() != get_parent() or not candidato.is_visible_in_tree() or not candidato.tem_comida():
			continue
		var distancia = global_position.distance_to(candidato.global_position)
		if distancia > distancia_minima:
			continue
		var consulta = PhysicsRayQueryParameters2D.create(global_position, candidato.global_position, collision_mask, [get_rid()])
		var obstaculo = get_world_2d().direct_space_state.intersect_ray(consulta)
		if not obstaculo.is_empty() and obstaculo["collider"] != candidato:
			continue
		mais_proximo = candidato
		distancia_minima = distancia
	return mais_proximo

func _passear() -> void:
	_cocho = null
	_tempo_comendo = 0.0
	if timer.is_stopped():
		super._obter_estado()
	_controle()

func _obter_estado() -> void:
	if _tempo_fuga_restante > 0.0 or is_instance_valid(_cocho):
		return
	super._obter_estado()

func _reagir_ao_personagem(corpo: Node2D) -> void:
	if not corpo.is_in_group("Jogador"):
		return
	_tempo_fuga_restante = tempo_fugindo
	_tempo_comendo = 0.0
	_cocho = null
	super._reagir_ao_personagem(corpo)

func _atualizar_postura(delta: float) -> void:
	if _tempo_ovo_restante < 0.0:
		return
	_tempo_ovo_restante = maxf(0.0, _tempo_ovo_restante - delta)
	if _tempo_ovo_restante == 0.0:
		botar_ovo()

func botar_ovo() -> void:
	if _tempo_ovo_restante != 0.0 or cena_ovo == null:
		return
	var ovo = cena_ovo.instantiate() as Node2D
	if ovo == null:
		return
	get_parent().add_child(ovo)
	ovo.global_position = global_position + Vector2(0, 10)
	_tempo_ovo_restante = -1.0
	_tempo_fome_restante = intervalo_refeicoes

func obter_estado_alimentacao() -> Dictionary:
	return {
		"ovo_restante": _tempo_ovo_restante,
		"fome_restante": _tempo_fome_restante,
		"fuga_restante": _tempo_fuga_restante
	}

func restaurar_estado_alimentacao(dados: Dictionary) -> void:
	_tempo_ovo_restante = maxf(-1.0, dados.get("ovo_restante", -1.0))
	_tempo_fome_restante = maxf(0.0, dados.get("fome_restante", 0.0))
	_tempo_fuga_restante = maxf(0.0, dados.get("fuga_restante", 0.0))
	# Comida só é descontada ao terminar; uma refeição interrompida pode recomeçar.
	_tempo_comendo = 0.0
	_cocho = null
