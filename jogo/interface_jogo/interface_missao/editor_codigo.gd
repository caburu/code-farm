class_name EditorCodigo 

extends Control

signal codigo_analisado_api(resultado_api: ResultadoAPI)

@onready var _code_edit = %CodeEdit
@onready var _requisicao_http = %RequisicaoHTTP

#const API_URL = "http://127.0.0.1:8000/analisar_codigo"
#const API_URL = "https://code-farm.onrender.com/analisar_codigo" API Antiga do Thomas
const API_URL = "https://code-farm-x5um.onrender.com/analisar_codigo"

func _ready():
	desativar()
	Global.conectar_sinal(Global, "dados_requisicao_prontos", Callable(self, "_ao_receber_dados_requisicao"))

func ativar() -> void:
	_code_edit.editable = true
	self.modulate = Color(1, 1, 1, 1)

func desativar() -> void:
	_code_edit.editable = false
	self.modulate = Color(0.6, 0.6, 0.6, 1.0)

func obter_codigo_digitado() -> String:
	return _code_edit.text

func limpar() -> void:
	_code_edit.text = ""

func obter_resultado_api() -> ResultadoAPI:
	return await codigo_analisado_api

func _ao_apertar_botao_limpar() -> void:
	limpar()

func _ao_apertar_botao_verificar() -> void:
	Global.emit_signal("solicitar_dados_requisicao")

func _ao_receber_dados_requisicao(dados: Dictionary) -> void:
	var headers = ["Content-Type: application/json"]
	var json_data = JSON.stringify(dados)
	
	_requisicao_http.request(API_URL, headers, HTTPClient.METHOD_POST, json_data)

func _ao_completar_requisicao_http(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var resultado_api = ResultadoAPI.new()

	if response_code == 200:
		var json_string = body.get_string_from_utf8()
		var resposta = JSON.parse_string(json_string)
		print("JSON decodificado:", resposta)

		var status_resposta = resposta.get("status", "erro_desconhecido")

		match status_resposta:
			"sucesso":
				resultado_api.definir_status(ResultadoAPI.Status.SUCESSO)
			"erro_sintatico":
				resultado_api.definir_status(ResultadoAPI.Status.ERRO_SINTATICO)
			"erro_semantico":
				resultado_api.definir_status(ResultadoAPI.Status.ERRO_SEMANTICO)
			"erro_desconhecido":
				resultado_api.definir_status(ResultadoAPI.Status.ERRO_DESCONHECIDO)
			_:
				resultado_api.definir_status(ResultadoAPI.Status.ERRO_DESCONHECIDO)
		
		resultado_api.definir_mensagens(resposta.get("mensagens", []))
		resultado_api.definir_dados(resposta.get("dados", {}))
	else:
		resultado_api.definir_status(ResultadoAPI.Status.ERRO_DESCONHECIDO)
		resultado_api.definir_mensagens(["Erro na requisição HTTP: código " + str(response_code)])
	
	codigo_analisado_api.emit(resultado_api)
