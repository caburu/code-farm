class_name Item

extends Resource

@export var nome: String
@export var icone: Texture2D
@export var pode_empilhar: bool = true
@export var descricao: String = ""
@export var tipo: String = ""
@export_file("*.tscn") var caminho_cena: String
@export var preco: int = 0
