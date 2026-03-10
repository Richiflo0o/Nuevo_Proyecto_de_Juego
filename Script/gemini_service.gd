# gemini_service.gd
# Autoload — nombre: GeminiService

extends Node

const API_KEY := Config.GEMINI_API_KEY
const API_URL := "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=" + API_KEY

signal pregunta_lista(datos: Dictionary)
signal error_api(mensaje: String)

var _tipo_actual := ""
var _http        : HTTPRequest

func _ready() -> void:
	# Crear HTTPRequest aquí para que tenga PROCESS_MODE_ALWAYS
	# antes de que el árbol pueda pausarse
	process_mode = Node.PROCESS_MODE_ALWAYS
	_http = HTTPRequest.new()
	_http.name = "HTTPRequest"
	_http.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_http)

func solicitar_pregunta(tipo: String) -> void:
	_tipo_actual = tipo
	var prompt := _construir_prompt(tipo)
	var body := JSON.stringify({
		"contents": [{"parts": [{"text": prompt}]}],
		"generationConfig": {"temperature": 0.7}
	})
	var headers := ["Content-Type: application/json"]

	if _http.request_completed.is_connected(_on_respuesta):
		_http.request_completed.disconnect(_on_respuesta)
	_http.request_completed.connect(_on_respuesta)

	var error := _http.request(API_URL, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		emit_signal("error_api", "Error al enviar petición: %d" % error)

func _construir_prompt(tipo: String) -> String:
	if tipo == "multiple":
		return """Eres un generador de preguntas para un videojuego educativo sobre Programación Orientada a Objetos (POO).

Genera UNA pregunta de opción múltiple sobre alguno de estos temas: clases, objetos, encapsulamiento, atributos, métodos, instancias.

Responde ÚNICAMENTE con este JSON exacto, sin explicaciones ni markdown:
{
  "tipo": "multiple",
  "pregunta": "¿Texto de la pregunta?",
  "opciones": ["opción A", "opción B", "opción C", "opción D"],
  "correcta": 0
}

Donde "correcta" es el índice (0-3) de la respuesta correcta.
El nivel de dificultad debe ser para principiantes."""
	else:
		return """Eres un generador de preguntas para un videojuego educativo sobre Programación Orientada a Objetos (POO).

Genera UN ejercicio de asociación (drag & drop) con EXACTAMENTE 2 pares: un concepto de POO y su definición.

Responde ÚNICAMENTE con este JSON exacto, sin explicaciones ni markdown:
{
  "tipo": "drag",
  "pregunta": "Arrastra cada concepto a su definición correcta:",
  "pares": [
    {"concepto": "NombreConcepto1", "definicion": "Definición corta 1"},
    {"concepto": "NombreConcepto2", "definicion": "Definición corta 2"}
  ]
}

Los conceptos deben ser de: clase, objeto, atributo, método, encapsulamiento, instancia, herencia.
Las definiciones deben ser cortas (máximo 5 palabras)."""

func _on_respuesta(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	print("=== _on_respuesta DISPARADO result=", result, " code=", response_code)
	_http.request_completed.disconnect(_on_respuesta)

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		emit_signal("error_api", "Error HTTP: %d" % response_code)
		return

	var texto := body.get_string_from_utf8()
	var json_response = JSON.parse_string(texto)

	if not json_response:
		emit_signal("error_api", "Error parseando respuesta de Gemini")
		return

	var contenido : String = json_response["candidates"][0]["content"]["parts"][0]["text"]
	contenido = contenido.strip_edges().replace("```json", "").replace("```", "").strip_edges()

	var datos = JSON.parse_string(contenido)
	if not datos:
		emit_signal("error_api", "La IA no devolvió JSON válido")
		return

	emit_signal("pregunta_lista", datos)
