# gemini_service.gd
# Autoload — nombre: GeminiService
# Ahora usa Groq API (gratis, sin tarjeta)
# Obtén tu key en: https://console.groq.com/keys

extends Node

# ── Reemplaza Config.GEMINI_API_KEY por tu Groq key ──────────────────────────
# En config.gd agrega: const GROQ_API_KEY := "gsk_..."
const API_KEY := Config.GROQ_API_KEY
const API_URL := "https://api.groq.com/openai/v1/chat/completions"
const MODELO  := "llama-3.1-8b-instant"

signal pregunta_lista(datos: Dictionary)
signal error_api(mensaje: String)

var _tipo_actual := ""
var _http : HTTPRequest
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_http = HTTPRequest.new()
	_http.name = "HTTPRequest"
	_http.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_http)

func solicitar_pregunta(tipo: String) -> void:
	_tipo_actual = tipo
	var prompt := _construir_prompt(tipo)

	var headers := [
		"Content-Type: application/json",
		"Authorization: Bearer " + API_KEY
	]
	var body := JSON.stringify({
		"model": MODELO,
		"messages": [{"role": "user", "content": prompt}],
		"temperature": 0.9,
		"max_tokens": 512
	})

	if _http.request_completed.is_connected(_on_respuesta):
		_http.request_completed.disconnect(_on_respuesta)
	_http.request_completed.connect(_on_respuesta)

	var error := _http.request(API_URL, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		emit_signal("error_api", "Error al enviar petición: %d" % error)

func _construir_prompt(tipo: String) -> String:
	var temas := ["clases", "objetos", "encapsulamiento", "atributos",
				  "métodos", "instancias", "constructores", "getters y setters"]
	var tema : String = temas[randi() % temas.size()]

	if tipo == "multiple":
		return """Eres un generador de preguntas para un videojuego educativo sobre POO.

Genera UNA pregunta de opción múltiple ÚNICAMENTE sobre este tema: %s
La pregunta debe ser DIFERENTE a preguntas básicas comunes.

Responde ÚNICAMENTE con este JSON exacto, sin explicaciones ni markdown:
{
  "tipo": "multiple",
  "pregunta": "¿Texto de la pregunta?",
  "opciones": ["opción A", "opción B", "opción C", "opción D"],
  "correcta": 0
}

Donde "correcta" es el índice (0-3) de la respuesta correcta.
Nivel: principiantes. Usa ejemplos creativos del mundo real.""" % tema
	else:
		var temas_drag := ["clase vs objeto", "atributo vs método",
						   "encapsulamiento vs herencia", "instancia vs clase"]
		var tema_drag : String = temas_drag[randi() % temas_drag.size()]
		return """Eres un generador de preguntas para un videojuego educativo sobre POO.

Genera UN ejercicio drag & drop sobre: %s
Con EXACTAMENTE 2 pares concepto-definición creativos.

Responde ÚNICAMENTE con este JSON exacto, sin markdown:
{
  "tipo": "drag",
  "pregunta": "Arrastra cada concepto a su definición correcta:",
  "pares": [
	{"concepto": "Concepto1", "definicion": "Definición corta"},
	{"concepto": "Concepto2", "definicion": "Definición corta"}
  ]
}

Definiciones máximo 5 palabras. Sé creativo.""" % tema_drag

func _on_respuesta(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	print("=== _on_respuesta DISPARADO result=", result, " code=", response_code)
	_http.request_completed.disconnect(_on_respuesta)

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		emit_signal("error_api", "Error HTTP: %d" % response_code)
		return

	var texto := body.get_string_from_utf8()
	var json_response = JSON.parse_string(texto)

	if not json_response:
		emit_signal("error_api", "Error parseando respuesta")
		return

	# Groq usa formato OpenAI: choices[0].message.content
	var contenido : String = json_response["choices"][0]["message"]["content"]
	contenido = contenido.strip_edges().replace("```json", "").replace("```", "").strip_edges()

	var datos = JSON.parse_string(contenido)
	if not datos:
		emit_signal("error_api", "La IA no devolvió JSON válido")
		return

	emit_signal("pregunta_lista", datos)
