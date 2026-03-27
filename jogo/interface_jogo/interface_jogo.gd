class_name InterfaceJogo extends Control

enum Interface {
	MENU_INICIAL,
	PADRAO,
	MISSAO,
	GLOSSARIO
}

@onready var interface_salvar_carregar: InterfaceSalvarCarregar = $InterfaceSalvarCarregar

@onready var _interfaces = {
	Interface.MENU_INICIAL: %InterfaceMenuInicial,
	Interface.PADRAO: %InterfacePadrao,
	Interface.MISSAO: %InterfaceMissao,
	Interface.GLOSSARIO: %InterfaceGlossario,
}

func _ready():
	_ocultar_todas_interfaces()
	pass

func _ocultar_todas_interfaces():
	for chave in _interfaces.keys():
		_interfaces[chave].hide()

func exibir_interface(qual_interface: Interface):
	_ocultar_todas_interfaces()
	
	var interface = _interfaces.get(qual_interface)
	if interface:
		interface.show()
		
		match qual_interface:
			Interface.MENU_INICIAL:
				pass
			
			Interface.PADRAO:
				pass
			
			Interface.MISSAO:
				obter_interface(Interface.PADRAO).show()
			
			Interface.GLOSSARIO:
				interface.abrir_glossario()

func obter_interface(qual_interface: Interface):
	return _interfaces.get(qual_interface)

func obter_interface_atual() -> Interface:
	for tipo in _interfaces.keys():
		if _interfaces[tipo].visible:
			return tipo
	return Interface.PADRAO
	
func abrir_menu_save_load(modo_salvar: bool) -> void:
	# Se for abrir para salvar, garantimos que o pause menu (se estiver aberto) suma
	# Mas mantenha o jogo pausado se já estiver
	
	interface_salvar_carregar.abrir_tela(modo_salvar)	
