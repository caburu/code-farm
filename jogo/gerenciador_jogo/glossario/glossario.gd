class_name Glossario

extends Resource

var _termos_disponiveis: Dictionary = {
	"print()": {
		"nome": "Função print()",
		"descricao": "A função print() é usada para exibir mensagens na tela (console). Ela é muito útil para mostrar resultados, textos ou acompanhar a execução do programa.",
		"tipo":"Exemplo:",
		"exemplo": "print(\"Olá, mundo!\")",
		"missao": 1
	},
	"#": {
		"nome": "# Comentários",
		"descricao": "Em Python, tudo que vem após o símbolo # em uma linha é ignorado pelo programa. Isso serve para deixar anotações no código, facilitando o entendimento.",
		"tipo":"Exemplo:",
		"exemplo": "# Isso é um comentário explicativo",
		"missao": 10
	},
	'"""': {
		"nome": '""" Comentários """',
		"descricao": "Usa-se três aspas duplas para escrever comentários que ocupam várias linhas. Eles são úteis para explicar melhor o funcionamento do código ou escrever descrições longas.",
		"tipo":"Exemplo:",
		"exemplo": "\"\"\"\nEste código faz parte do jogo Code Farm.\nEle ajuda a organizar e explicar o código faz.\n\"\"\"",
		"missao": 10
	},
	"variáveis": {
		"nome": "Variáveis",
		"descricao": "Variáveis são usadas para armazenar informações. Elas recebem um nome e podem guardar textos, números, listas e outros valores que podem mudar durante a execução do programa.",
		"tipo":"Exemplo:",
		"exemplo": "copo = \"água\"",
		"missao": 10
	},
	"for": {
		"nome": "Laço for",
		"descricao": "O laço for é usado para repetir uma ação várias vezes. Com ele, você pode executar um bloco de código para cada valor dentro de uma sequência ou intervalo.",
		"tipo":"Exemplo:",
		"exemplo": "for i in range(5):\n\tprint(\"Repetição número\", i)",
		"missao": 10
	},
	"if": {
		"nome": "Condicional if",
		"descricao": "O comando if é usado para executar uma parte do código somente se uma condição for verdadeira.",
		"tipo":"Exemplo:",
		"exemplo": "if copo == \"água\":\n\tprint(\"É água mesmo!\")",
		"missao": 10
	},
	"elif": {
		"nome": "Condicional elif",
		"descricao": "elif é a abreviação de 'else if'. Ele permite testar uma nova condição se a anterior (if) for falsa.",
		"tipo":"Exemplo:",
		"exemplo": "elif copo == \"suco\":\n\tprint(\"É suco!\")",
		"missao": 10
	},
	"else": {
		"nome": "Condicional else",
		"descricao": "O else é usado quando nenhuma das condições anteriores (if ou elif) foi verdadeira. Ele executa um código alternativo.",
		"tipo":"Exemplo:",
		"exemplo": "else:\n\tprint(\"Não sei o que tem nesse copo!\")",
		"missao": 10
	},
}

# --- DADOS DAS MISSÕES (NOVO) ---

var _missoes_disponiveis: Dictionary = {
	"missao_0": {
		"nome": "O Legado do Avô",
		"descricao": "14 de Agosto Meus ossos já não aguentam o peso da enxada... Trabalhei no porão em algo que pode salvar esta fazenda. Deixei o projeto escondido sob o tapete da sala. Por favor, termine o que comecei.'",
		"tipo":"Tarefas:",
		"exemplo": "Encontre a passagem sob o tapete e descubra o projeto no porão.",
		"missao": 0
	},
	"missao_1": {
	"nome": "Introdução ao AGR.O",
	"descricao": "O projeto secreto do meu avô era um robô de fazenda! O AGR.O parece ser tecnologia de ponta, mas está com o banco de dados desatualizado. Precisei me registrar como o novo administrador e dar uma identidade oficial para a propriedade.",
	"tipo": "Tarefas:",
	"exemplo": "1. Registre seu nome no sistema do robô usando o comando print().\n2. Interaja com a placa na entrada e use o print() para dar um nome à fazenda.",
	"missao": 1
	},
	"missao_2": {
	"nome": "Nomeando a fazenda",
	"descricao": "O AGR.O é tem bastante potencial, vamos ver o que ele é capaz de fazer. Vou começar a dar a essa fazenda a minha cara. Primeiro ela precisa um nome.",
	"tipo": "Tarefas:",
	"exemplo": "Registre o nome da fazenda com a ajuda do robô usando o comando print().\n1. Interaja com a placa na entrada e use o print() para dar um nome à fazenda.",
	"missao": 2
	}
}



# --- FUNÇÕES DAS MISSÕES (NOVO) ---

func _obter_missoes_desbloqueadas() -> Dictionary:
	var desbloqueadas := {}
	for missao in _missoes_disponiveis:
		var dados = _missoes_disponiveis[missao]
		if dados.get("missao") <= Global.missao_atual:
			desbloqueadas[missao] = dados
	return desbloqueadas

func obter_lista_missoes() -> Array:
	return _obter_missoes_desbloqueadas().keys()

func obter_dados_missao(missao: String) -> Dictionary:
	return _obter_missoes_desbloqueadas()[missao]

func _obter_termos_aprendidos() -> Dictionary:
	var aprendidos := {}
	for termo in _termos_disponiveis:
		var dados = _termos_disponiveis[termo]
		if dados.get("missao") <= Global.missao_atual:
			aprendidos[termo] = dados
	return aprendidos

func obter_lista_termos_aprendidos() -> Array:
	return _obter_termos_aprendidos().keys()

func obter_dados_termo(termo: String) -> Dictionary:
	return _obter_termos_aprendidos()[termo]

func possui_termo(termo: String) -> bool:
	return _obter_termos_aprendidos().has(termo)
