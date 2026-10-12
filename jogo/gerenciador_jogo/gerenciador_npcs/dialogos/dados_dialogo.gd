class_name DadosDialogo
extends Resource

@export_multiline var falas: Array[String] = []

@export_group("Sistema de Escolhas")
@export var tem_escolhas: bool = false
@export var pergunta: String = "O que deseja fazer?"
@export var opcoes: Array[String] = []
@export var acoes: Array[String] = []
@export var proximas_rotas: Array[DadosDialogo] = []
