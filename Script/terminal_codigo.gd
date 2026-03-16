# terminal_codigo.gd
# Nodo: CanvasLayer  (hijo de TerminalcodigoPOO en terminalcodigo_poo.tscn)
#
# Usa los nodos YA EXISTENTES en la escena. Solo agrega PanelPista como nuevo.
#
# Nodos existentes que usa este script:
#   $Panel/TituloLabel          (Label)
#   $Panel/FaseEjercicio/InstruccionLabel  (Label)
#   $Panel/FaseEjercicio/CodigoLabel       (RichTextLabel)
#   $Panel/FaseEjercicio/InputField        (LineEdit)
#   $Panel/FaseEjercicio/ValidarBtn        (Button)
#   $Panel/FaseEjercicio/FeedbackLabel     (Label)
#   $Panel/CerrarBtn            (Button)
#
# Nodo NUEVO que debes agregar manualmente en Godot al Panel:
#   $PanelPista (Panel) con hijos:
#     - TituloLabel (Label)
#     - ContenidoLabel (RichTextLabel)

extends CanvasLayer

signal respuesta_correcta
signal respuesta_incorrecta

const PANEL_PISTA_SIZE := Vector2(280, 190)
const MARGEN           := 16.0

const LECCIONES := [
	# ── Terminal 1: Clases ───────────────────────────────────────────────────
	{
		"titulo":      "> TERMINAL_01 — Clases",
		"instruccion": "Define la clase Vehiculo:",
		"codigo":
			"[color=yellow]___[/color] Vehiculo\n{\n    public string marca;\n    public int velocidad;\n}",
		"respuesta":    "class",
		"pista_titulo": "💡 Clases en C#",
		"pista":
			"Una [b]clase[/b] es una plantilla.\n\n"
			+ "[color=gray]// Ejemplo:[/color]\n"
			+ "[color=cyan]class[/color] [color=yellow]Personaje[/color] {\n"
			+ "    public string nombre;\n"
			+ "}",
	},
	# ── Terminal 2: Objetos ──────────────────────────────────────────────────
	{
		"titulo":      "> TERMINAL_02 — Objetos",
		"instruccion": "Crea un objeto de la clase Vehiculo:",
		"codigo":
			"Vehiculo miAuto = [color=yellow]___[/color] Vehiculo();",
		"respuesta":    "new",
		"pista_titulo": "💡 Objetos en C#",
		"pista":
			"Un [b]objeto[/b] es una instancia de una clase.\n\n"
			+ "[color=gray]// Ejemplo:[/color]\n"
			+ "[color=yellow]Personaje[/color] p = [color=cyan]new[/color] [color=yellow]Personaje[/color]();\n"
			+ "p.nombre = [color=green]\"Héroe\"[/color];",
	},
	# ── Terminal 3: Atributos ────────────────────────────────────────────────
	{
		"titulo":      "> TERMINAL_03 — Atributos",
		"instruccion": "Declara el atributo privado _combustible:",
		"codigo":
			"class Vehiculo\n{\n    [color=yellow]___[/color] float _combustible;\n}",
		"respuesta":    "private",
		"pista_titulo": "💡 Atributos privados",
		"pista":
			"[b]private[/b] oculta el atributo.\n\n"
			+ "[color=gray]// Convención: guion bajo[/color]\n"
			+ "[color=red]private[/color] int _vida;\n"
			+ "[color=red]private[/color] string _nombre;",
	},
	# ── Terminal 4: Métodos ──────────────────────────────────────────────────
	{
		"titulo":      "> TERMINAL_04 — Métodos",
		"instruccion": "Completa el tipo de retorno del método Avanzar:",
		"codigo":
			"public [color=yellow]___[/color] Avanzar()\n{\n    Console.WriteLine(\"Avanzando...\");\n}",
		"respuesta":    "void",
		"pista_titulo": "💡 Métodos en C#",
		"pista":
			"[b]void[/b] = no devuelve nada.\n\n"
			+ "public [color=cyan]void[/color] Atacar() { ... }\n"
			+ "public [color=cyan]int[/color] ObtenerVida() { ... }",
	},
]

# ── Nodos existentes en la escena ─────────────────────────────────────────────
@onready var _titulo_label   : Label         = $Panel/TituloLabel
@onready var _instruccion    : Label         = $Panel/FaseEjercicio/InstruccionLabel
@onready var _codigo         : RichTextLabel = $Panel/FaseEjercicio/CodigoLabel
@onready var _input_field    : LineEdit      = $Panel/FaseEjercicio/InputField
@onready var _validar_btn    : Button        = $Panel/FaseEjercicio/ValidarBtn
@onready var _feedback       : Label         = $Panel/FaseEjercicio/FeedbackLabel
@onready var _cerrar_btn     : Button        = $Panel/CerrarBtn

# ── Nodo nuevo (agrégalo al Panel en Godot) ───────────────────────────────────
# Si no existe, las pistas simplemente no aparecen (no rompe nada)
@onready var _panel_pista    : Panel         = get_node_or_null("Panel/PanelPista")
@onready var _pista_titulo   : Label         = get_node_or_null("Panel/PanelPista/TituloLabel")
@onready var _pista_contenido: RichTextLabel = get_node_or_null("Panel/PanelPista/ContenidoLabel")

@export var leccion_id : int = 0

var _leccion       : Dictionary = {}
var _resuelta      := false
var _validando     := false
var _pista_visible := false

# ── Ciclo de vida ─────────────────────────────────────────────────────────────
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	# Ocultar fases antiguas si existen en la escena
	var fase_exp = get_node_or_null("Panel/FaseExplicacion")
	if fase_exp:
		fase_exp.visible = false

	# Posicionar panel pista en esquina superior derecha
	if _panel_pista:
		_posicionar_pista()
		_panel_pista.visible = false

	_validar_btn.pressed.connect(_on_validar)
	_cerrar_btn.pressed.connect(_cerrar)
	_input_field.text_submitted.connect(func(_t): _on_validar())

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_H:
			_toggle_pista()
			get_viewport().set_input_as_handled()
	if event.is_action_pressed("ui_cancel"):
		_cerrar()
		get_viewport().set_input_as_handled()

func _posicionar_pista() -> void:
	var screen := get_viewport().get_visible_rect().size
	_panel_pista.set_deferred("size", PANEL_PISTA_SIZE)
	_panel_pista.set_deferred("position", Vector2(
		screen.x - PANEL_PISTA_SIZE.x - MARGEN,
		MARGEN
	))

# ── API pública ───────────────────────────────────────────────────────────────
func abrir() -> void:
	if _resuelta:
		return
	_leccion = LECCIONES[clamp(leccion_id, 0, LECCIONES.size() - 1)]
	_poblar_ui()
	visible = true
	# NO pausa el juego
	_input_field.grab_focus()

func _poblar_ui() -> void:
	_titulo_label.text          = _leccion["titulo"]
	_instruccion.text           = _leccion["instruccion"]
	_codigo.text                = "[font_size=13]" + _leccion["codigo"] + "[/font_size]"
	_input_field.text           = ""
	_input_field.placeholder_text = "Escribe aquí... [H] pista  [Esc] cerrar"
	_feedback.text              = ""
	_validar_btn.disabled       = false
	_input_field.editable       = true

	# Cargar pista si el panel existe
	if _pista_titulo:
		_pista_titulo.text = _leccion["pista_titulo"]
	if _pista_contenido:
		_pista_contenido.text = "[font_size=12]" + _leccion["pista"] + "[/font_size]"
	if _panel_pista:
		_panel_pista.visible = false
	_pista_visible = false

# ── Toggle pista ──────────────────────────────────────────────────────────────
func _toggle_pista() -> void:
	if not _panel_pista:
		return
	_pista_visible = not _pista_visible
	_panel_pista.visible = _pista_visible
	if _pista_visible:
		_panel_pista.modulate.a = 0.0
		var tween := create_tween()
		tween.tween_property(_panel_pista, "modulate:a", 1.0, 0.2)

# ── Validación ────────────────────────────────────────────────────────────────
func _on_validar() -> void:
	if _validando:
		return
	var respuesta := _input_field.text.strip_edges()
	if respuesta.is_empty():
		_feedback.text = "Escribe algo primero."
		return

	_validando = true
	_validar_btn.disabled = true
	_feedback.text = "..."
	_validar_con_ia(respuesta)

func _validar_con_ia(respuesta: String) -> void:
	var http := HTTPRequest.new()
	http.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(http)

	var prompt := (
		"Valida si esta respuesta de C# es correcta.\n"
		+ "Ejercicio: %s\nEsperado: '%s'\nRespuesta: '%s'\n"
		+ "Responde SOLO con JSON sin markdown: "
		+ "{\"correcto\": true/false, \"explicacion\": \"frase corta en español\"}"
	) % [_leccion["instruccion"], _leccion["respuesta"], respuesta]

	var headers := [
		"Content-Type: application/json",
		"Authorization: Bearer " + Config.GROQ_API_KEY
	]
	var body := JSON.stringify({
		"model": "llama-3.1-8b-instant",
		"messages": [{"role": "user", "content": prompt}],
		"temperature": 0.1,
		"max_tokens": 60
	})
	http.request_completed.connect(
		func(r, c, _h, rb): _on_ia_respuesta(r, c, rb, respuesta, http)
	)
	http.request("https://api.groq.com/openai/v1/chat/completions",
		headers, HTTPClient.METHOD_POST, body)

func _on_ia_respuesta(result: int, code: int, body: PackedByteArray, respuesta: String, http: HTTPRequest) -> void:
	http.queue_free()
	_validando = false
	_validar_btn.disabled = false

	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		_validar_local(respuesta)
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if not json:
		_validar_local(respuesta)
		return

	var contenido : String = json["choices"][0]["message"]["content"]
	contenido = contenido.strip_edges().replace("```json","").replace("```","").strip_edges()
	var datos = JSON.parse_string(contenido)
	if not datos or not datos.has("correcto"):
		_validar_local(respuesta)
		return

	_aplicar_resultado(datos["correcto"], datos.get("explicacion", ""))

func _validar_local(respuesta: String) -> void:
	var esperada := (_leccion["respuesta"] as String).strip_edges().to_lower()
	var dada     := respuesta.strip_edges().to_lower()
	var correcto := (dada == esperada)
	var msg : String = "✓ ¡Correcto!" if correcto else ("✗ Incorrecto.  [H] para ver la pista")
	_aplicar_resultado(correcto, msg)

func _aplicar_resultado(correcto: bool, explicacion: String) -> void:
	if correcto:
		_feedback.text = "✓  " + explicacion
		_feedback.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4))
		_input_field.editable   = false
		_validar_btn.disabled   = true
		_resuelta               = true
		if _panel_pista:
			_panel_pista.visible = false
		await get_tree().create_timer(1.5).timeout
		_cerrar()
		respuesta_correcta.emit()
	else:
		_feedback.text = "✗  " + explicacion
		_feedback.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45))
		_input_field.text = ""
		_input_field.grab_focus()
		respuesta_incorrecta.emit()

func _cerrar() -> void:
	visible = false
	if _panel_pista:
		_panel_pista.visible = false
