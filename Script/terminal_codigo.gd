# terminal_codigo.gd
# Nodo: CanvasLayer
# Terminal pedagógica: primero explica el concepto, luego evalúa con ejercicio.
#
# Árbol de nodos:
# TerminalCodigo (CanvasLayer)
# └── Panel
#     ├── TituloLabel       (Label)         ← "> TERMINAL_X"
#     ├── FaseExplicacion   (VBoxContainer) ← visible en fase 1
#     │   ├── ConceptoLabel (Label)         ← nombre del concepto
#     │   ├── ExplicacionLabel (RichTextLabel) ← explicación
#     │   ├── EjemploLabel  (RichTextLabel) ← ejemplo en C#
#     │   └── ContinuarBtn  (Button)        ← "Entendido → Practicar"
#     ├── FaseEjercicio     (VBoxContainer) ← visible en fase 2
#     │   ├── InstruccionLabel (Label)      ← qué debe hacer
#     │   ├── CodigoLabel   (RichTextLabel) ← código con ___
#     │   ├── InputField    (LineEdit)      ← escribe aquí
#     │   ├── ValidarBtn    (Button)        ← "Validar"
#     │   └── FeedbackLabel (Label)         ← resultado
#     └── CerrarBtn         (Button)        ← "Cerrar"

extends CanvasLayer

signal respuesta_correcta
signal respuesta_incorrecta

const PANEL_SIZE := Vector2(620, 480)

# ── Contenido pedagógico de las 4 terminales ─────────────────────────────────
# Cada terminal tiene: tema, explicación, ejemplo visual y ejercicio.
# El índice (0-3) se asigna desde el nodo padre con @export var terminal_id.

const LECCIONES := [
	# ── Terminal 1: ¿Qué es una Clase? ──────────────────────────────────────
	{
		"titulo":      "TERMINAL_01 — Clases",
		"concepto":    "¿Qué es una CLASE?",
		"explicacion": (
			"Una [b]clase[/b] es una [color=cyan]plantilla o molde[/color] que define\n"
			+ "cómo será un tipo de objeto: qué datos tendrá y qué acciones podrá hacer.\n\n"
			+ "Piensa en ella como el [color=yellow]plano de un edificio[/color]:\n"
			+ "el plano no es el edificio, pero describe exactamente cómo construirlo."
		),
		"ejemplo": (
			"[color=gray]// Definición de una clase en C#[/color]\n"
			+ "[color=cyan]class[/color] [color=yellow]Personaje[/color]\n"
			+ "{\n"
			+ "    [color=cyan]public string[/color] nombre;\n"
			+ "    [color=cyan]public int[/color]    vida;\n"
			+ "}"
		),
		"instruccion":  "Completa la definición de la clase:",
		"codigo":       "___ Vehiculo\n{\n    public string marca;\n    public int velocidad;\n}",
		"respuesta":    "class",
		"concepto_eval": "clase en C#",
		"pista":        "La palabra clave en C# para definir una clase es..."
	},

	# ── Terminal 2: ¿Qué es un Objeto? ──────────────────────────────────────
	{
		"titulo":      "TERMINAL_02 — Objetos",
		"concepto":    "¿Qué es un OBJETO?",
		"explicacion": (
			"Un [b]objeto[/b] es una [color=cyan]instancia concreta[/color] de una clase.\n"
			+ "Si la clase es el plano, el objeto es [color=yellow]el edificio ya construido[/color].\n\n"
			+ "Cada objeto tiene sus propios valores:\n"
			+ "dos objetos de la misma clase pueden tener datos distintos."
		),
		"ejemplo": (
			"[color=gray]// Crear un objeto (instanciar) en C#[/color]\n"
			+ "[color=yellow]Personaje[/color] heroe = [color=cyan]new[/color] [color=yellow]Personaje[/color]();\n"
			+ "heroe.nombre = [color=green]\"Compilador\"[/color];\n"
			+ "heroe.vida   = [color=orange]100[/color];\n\n"
			+ "[color=gray]// Otro objeto de la misma clase, datos distintos[/color]\n"
			+ "[color=yellow]Personaje[/color] villano = [color=cyan]new[/color] [color=yellow]Personaje[/color]();\n"
			+ "villano.nombre = [color=green]\"Bug_Final\"[/color];"
		),
		"instruccion":  "Instancia un objeto de la clase Vehiculo:",
		"codigo":       "Vehiculo miAuto = ___ Vehiculo();",
		"respuesta":    "new",
		"concepto_eval": "instanciar un objeto en C#",
		"pista":        "Para crear un objeto en C# se usa la palabra clave..."
	},

	# ── Terminal 3: Atributos ────────────────────────────────────────────────
	{
		"titulo":      "TERMINAL_03 — Atributos",
		"concepto":    "¿Qué son los ATRIBUTOS?",
		"explicacion": (
			"Los [b]atributos[/b] (o campos) son las [color=cyan]variables que pertenecen[/color]\n"
			+ "a una clase. Representan las [color=yellow]características[/color] del objeto.\n\n"
			+ "En C# se recomienda declararlos [color=red]private[/color] para protegerlos\n"
			+ "(encapsulamiento) y acceder a ellos solo mediante métodos o propiedades."
		),
		"ejemplo": (
			"[color=cyan]class[/color] [color=yellow]Personaje[/color]\n"
			+ "{\n"
			+ "    [color=red]private string[/color] _nombre;  [color=gray]// atributo privado[/color]\n"
			+ "    [color=red]private int[/color]    _vida;    [color=gray]// atributo privado[/color]\n\n"
			+ "    [color=cyan]public string[/color] Nombre    [color=gray]// propiedad pública[/color]\n"
			+ "    {\n"
			+ "        get { return _nombre; }\n"
			+ "        set { _nombre = value; }\n"
			+ "    }\n"
			+ "}"
		),
		"instruccion":  "Declara un atributo privado para guardar el combustible:",
		"codigo":       "class Vehiculo\n{\n    ___ float _combustible;\n}",
		"respuesta":    "private",
		"concepto_eval": "modificador de acceso en C#",
		"pista":        "Para ocultar un atributo se usa el modificador de acceso..."
	},

	# ── Terminal 4: Métodos ──────────────────────────────────────────────────
	{
		"titulo":      "TERMINAL_04 — Métodos",
		"concepto":    "¿Qué son los MÉTODOS?",
		"explicacion": (
			"Los [b]métodos[/b] son las [color=cyan]acciones o comportamientos[/color]\n"
			+ "que puede realizar un objeto. Son funciones definidas dentro de la clase.\n\n"
			+ "Si los atributos son [color=yellow]\"lo que el objeto sabe\"[/color],\n"
			+ "los métodos son [color=cyan]\"lo que el objeto puede hacer\"[/color]."
		),
		"ejemplo": (
			"[color=cyan]class[/color] [color=yellow]Personaje[/color]\n"
			+ "{\n"
			+ "    [color=red]private int[/color] _vida = [color=orange]100[/color];\n\n"
			+ "    [color=gray]// Método público que modifica un atributo[/color]\n"
			+ "    [color=cyan]public void[/color] RecibirDanio([color=cyan]int[/color] cantidad)\n"
			+ "    {\n"
			+ "        _vida -= cantidad;\n"
			+ "    }\n\n"
			+ "    [color=gray]// Método que retorna un valor[/color]\n"
			+ "    [color=cyan]public int[/color] ObtenerVida()\n"
			+ "    {\n"
			+ "        return _vida;\n"
			+ "    }\n"
			+ "}"
		),
		"instruccion":  "Completa el método que hace avanzar el vehículo:",
		"codigo":       "class Vehiculo\n{\n    public ___ Avanzar()\n    {\n        Console.WriteLine(\"Avanzando...\");\n    }\n}",
		"respuesta":    "void",
		"concepto_eval": "tipo de retorno de un método en C#",
		"pista":        "Un método que no retorna ningún valor usa el tipo..."
	},
]

# ── Nodos ─────────────────────────────────────────────────────────────────────
@onready var _panel             : Panel          = $Panel
@onready var _titulo_label      : Label          = $Panel/TituloLabel
@onready var _fase_explicacion  : VBoxContainer  = $Panel/FaseExplicacion
@onready var _concepto_label    : Label          = $Panel/FaseExplicacion/ConceptoLabel
@onready var _explicacion_label : RichTextLabel  = $Panel/FaseExplicacion/ExplicacionLabel
@onready var _ejemplo_label     : RichTextLabel  = $Panel/FaseExplicacion/EjemploLabel
@onready var _continuar_btn     : Button         = $Panel/FaseExplicacion/ContinuarBtn
@onready var _fase_ejercicio    : VBoxContainer  = $Panel/FaseEjercicio
@onready var _instruccion_label : Label          = $Panel/FaseEjercicio/InstruccionLabel
@onready var _codigo_label      : RichTextLabel  = $Panel/FaseEjercicio/CodigoLabel
@onready var _input             : LineEdit       = $Panel/FaseEjercicio/InputField
@onready var _validar_btn       : Button         = $Panel/FaseEjercicio/ValidarBtn
@onready var _feedback_label    : Label          = $Panel/FaseEjercicio/FeedbackLabel
@onready var _cerrar_btn        : Button         = $Panel/CerrarBtn

# ── Config ─────────────────────────────────────────────────────────────────────
# Asigna en el Inspector del nodo padre (0=Clases, 1=Objetos, 2=Atributos, 3=Métodos)
@export var leccion_id : int = 0

# ── Estado ────────────────────────────────────────────────────────────────────
var _leccion      : Dictionary = {}
var _validando    := false
var _resuelta     := false

# ── Ciclo de vida ─────────────────────────────────────────────────────────────
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_centrar_panel()
	_continuar_btn.pressed.connect(_mostrar_ejercicio)
	_validar_btn.pressed.connect(_on_validar)
	_cerrar_btn.pressed.connect(_cerrar)
	_input.text_submitted.connect(func(_t): _on_validar())

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_cerrar()
		get_viewport().set_input_as_handled()

func _centrar_panel() -> void:
	var screen_size := get_viewport().get_visible_rect().size
	_panel.set_deferred("position", (screen_size - PANEL_SIZE) / 2)
	_panel.set_deferred("size", PANEL_SIZE)

# ── API pública ───────────────────────────────────────────────────────────────
func abrir() -> void:
	if _resuelta:
		return
	_leccion = LECCIONES[clamp(leccion_id, 0, LECCIONES.size() - 1)]
	_mostrar_explicacion()
	visible = true
	get_tree().paused = true

# ── Fase 1: Explicación ───────────────────────────────────────────────────────
func _mostrar_explicacion() -> void:
	_titulo_label.text        = _leccion["titulo"]
	_concepto_label.text      = _leccion["concepto"]
	_explicacion_label.text   = _leccion["explicacion"]
	_ejemplo_label.text       = "[font_size=13][code]" + _leccion["ejemplo"] + "[/code][/font_size]"
	_fase_explicacion.visible = true
	_fase_ejercicio.visible   = false

# ── Fase 2: Ejercicio ─────────────────────────────────────────────────────────
func _mostrar_ejercicio() -> void:
	_fase_explicacion.visible = false
	_fase_ejercicio.visible   = true
	_feedback_label.text      = ""
	_input.text               = ""
	_instruccion_label.text   = _leccion["instruccion"]

	var codigo : String = _leccion["codigo"]
	_codigo_label.text = (
		"[font_size=13]"
		+ codigo.replace("___", "[color=yellow][b]___[/b][/color]")
		+ "[/font_size]"
	)
	_input.grab_focus()

# ── Validación ────────────────────────────────────────────────────────────────
func _on_validar() -> void:
	if _validando:
		return
	var respuesta := _input.text.strip_edges()
	if respuesta.is_empty():
		_feedback_label.text = "Escribe algo primero..."
		return

	_validando = true
	_validar_btn.disabled = true
	_feedback_label.text  = "Analizando respuesta..."
	_validar_con_ia(respuesta)

func _validar_con_ia(respuesta: String) -> void:
	var prompt := """Eres un validador de ejercicios de C# sobre POO para universitarios.

Concepto evaluado: %s
Código con espacio en blanco: %s
Respuesta esperada: "%s"
Respuesta del estudiante: "%s"

¿Es correcta o equivalente lógicamente?
Responde ÚNICAMENTE con este JSON, sin markdown:
{"correcto": true, "explicacion": "Una oración en español explicando por qué es correcto o incorrecto"}

Acepta variantes válidas (mayúsculas, espacios extra). Sé justo con principiantes.""" % [
		_leccion["concepto_eval"],
		_leccion["codigo"],
		_leccion["respuesta"],
		respuesta
	]

	var http := HTTPRequest.new()
	http.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(http)

	var headers := [
		"Content-Type: application/json",
		"Authorization: Bearer " + Config.GROQ_API_KEY
	]
	var body := JSON.stringify({
		"model": "llama-3.1-8b-instant",
		"messages": [{"role": "user", "content": prompt}],
		"temperature": 0.1,
		"max_tokens": 120
	})

	http.request_completed.connect(
		func(result, code, _h, rb): _on_validacion_lista(result, code, rb, respuesta, http)
	)
	http.request("https://api.groq.com/openai/v1/chat/completions",
		headers, HTTPClient.METHOD_POST, body)

func _on_validacion_lista(result: int, code: int, body: PackedByteArray, respuesta: String, http: HTTPRequest) -> void:
	http.queue_free()
	_validando = false
	_validar_btn.disabled = false

	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		_validar_local(respuesta)
		return

	var json_resp = JSON.parse_string(body.get_string_from_utf8())
	if not json_resp:
		_validar_local(respuesta)
		return

	var contenido : String = json_resp["choices"][0]["message"]["content"]
	contenido = contenido.strip_edges().replace("```json","").replace("```","").strip_edges()

	var datos = JSON.parse_string(contenido)
	if not datos or not datos.has("correcto"):
		_validar_local(respuesta)
		return

	_mostrar_resultado(datos["correcto"], datos.get("explicacion", ""))

func _validar_local(respuesta: String) -> void:
	var esperada : String = (_leccion["respuesta"] as String).strip_edges().to_lower()
	var dada     : String = respuesta.strip_edges().to_lower()
	var correcto : bool   = (dada == esperada)
	var msg      : String = "Respuesta esperada: [b]%s[/b]" % _leccion["respuesta"]
	if not correcto:
		msg += "\nPista: " + _leccion["pista"]
	_mostrar_resultado(correcto, msg)

func _mostrar_resultado(correcto: bool, explicacion: String) -> void:
	if correcto:
		_feedback_label.text = "✓ Correcto. " + explicacion
		_feedback_label.add_theme_color_override("font_color", Color.GREEN)
		_input.editable       = false
		_validar_btn.disabled = true
		_resuelta             = true
		await get_tree().create_timer(2.0).timeout
		_cerrar()
		respuesta_correcta.emit()
	else:
		_feedback_label.text = "✗ Incorrecto. " + explicacion
		_feedback_label.add_theme_color_override("font_color", Color.RED)
		_input.text = ""
		_input.grab_focus()
		respuesta_incorrecta.emit()

func _cerrar() -> void:
	visible = false
	get_tree().paused = false
