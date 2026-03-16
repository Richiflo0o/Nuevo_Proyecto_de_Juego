# gemini_service.gd
# Autoload — nombre: GeminiService
# Usa Groq API. Key en config.gd: const GROQ_API_KEY := "gsk_..."

extends Node

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
		"temperature": 0.7,
		"max_tokens": 400
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
		return (
			"Eres un generador de preguntas para un videojuego educativo sobre POO.\n"
			+ "Genera UNA pregunta de opción múltiple sobre: " + tema + "\n\n"
			+ "IMPORTANTE: Responde ÚNICAMENTE con el JSON, sin texto antes ni después, sin markdown, sin explicaciones.\n"
			+ "Formato exacto:\n"
			+ "{\"tipo\":\"multiple\",\"pregunta\":\"texto\",\"opciones\":[\"A\",\"B\",\"C\",\"D\"],\"correcta\":0}"
		)
	else:
		var temas_drag := ["clase vs objeto", "atributo vs método",
						   "encapsulamiento vs herencia", "instancia vs clase"]
		var tema_drag : String = temas_drag[randi() % temas_drag.size()]
		return (
			"Eres un generador de preguntas para un videojuego educativo sobre POO.\n"
			+ "Genera UN ejercicio drag & drop sobre: " + tema_drag + "\n\n"
			+ "IMPORTANTE: Responde ÚNICAMENTE con el JSON, sin texto antes ni después, sin markdown.\n"
			+ "Formato exacto:\n"
			+ "{\"tipo\":\"drag\",\"pregunta\":\"Arrastra cada concepto:\",\"pares\":[{\"concepto\":\"X\",\"definicion\":\"Y\"},{\"concepto\":\"A\",\"definicion\":\"B\"}]}"
		)

func _on_respuesta(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_http.request_completed.disconnect(_on_respuesta)

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		emit_signal("error_api", "Error HTTP: %d" % response_code)
		return

	var texto := body.get_string_from_utf8()
	var json_response = JSON.parse_string(texto)

	if not json_response:
		emit_signal("error_api", "Error parseando respuesta del servidor")
		return

	var contenido : String = json_response["choices"][0]["message"]["content"]

	# ── Parser robusto: extrae el bloque JSON aunque haya texto extra ─────────
	var datos = _extraer_json(contenido)
	if not datos:
		emit_signal("error_api", "La IA no devolvió JSON válido")
		return

	emit_signal("pregunta_lista", datos)

# Extrae el primer bloque {...} válido del texto, ignorando texto extra
func _extraer_json(texto: String) -> Variant:
	# 1. Intentar parsear directo (caso ideal)
	var limpio := texto.strip_edges()
	var resultado = JSON.parse_string(limpio)
	if resultado:
		return resultado

	# 2. Quitar markdown ```json ... ```
	limpio = limpio.replace("```json", "").replace("```", "").strip_edges()
	resultado = JSON.parse_string(limpio)
	if resultado:
		return resultado

	# 3. Buscar el primer { y el último } para extraer solo el bloque JSON
	var inicio := texto.find("{")
	var fin    := texto.rfind("}")
	if inicio != -1 and fin != -1 and fin > inicio:
		var bloque := texto.substr(inicio, fin - inicio + 1)
		resultado = JSON.parse_string(bloque)
		if resultado:
			return resultado

	# 4. No se pudo extraer
	return null
