# terminal_ui.gd
# Nodo raíz: CanvasLayer
# Árbol de nodos requerido:
# TerminalUI (CanvasLayer)
# └── Panel
#     ├── PreguntaLabel (Label)
#     ├── TipoA (VBoxContainer)
#     │   ├── Opcion0..3 (Button)
#     ├── TipoB (GridContainer)  ← columns = 2
#     ├── FeedbackLabel (Label)
#     └── CerrarBtn (Button)

extends CanvasLayer

# ── Señales ───────────────────────────────────────────────────────────────────
signal respuesta_correcta
signal terminal_cerrada

# ── Constantes ────────────────────────────────────────────────────────────────
const PANEL_SIZE := Vector2(500, 400)

# Banco local de preguntas (fallback si Gemini falla)
const PREGUNTAS := [
	{
		"tipo": "multiple",
		"pregunta": "¿Qué es una CLASE en POO?",
		"opciones": [
			"Una instancia específica de un objeto",
			"Una plantilla que define atributos y métodos",
			"Una función que retorna un valor",
			"Un tipo de variable global"
		],
		"correcta": 1
	},
	{
		"tipo": "multiple",
		"pregunta": "¿Cuál de estos es un ejemplo de OBJETO?",
		"opciones": [
			"La definición de 'Perro' con sus características",
			"El concepto abstracto de 'Animal'",
			"Mi perro 'Fido', con nombre y edad específicos",
			"Una función llamada ladrar()"
		],
		"correcta": 2
	},
	{
		"tipo": "multiple",
		"pregunta": "¿Qué es el ENCAPSULAMIENTO?",
		"opciones": [
			"Heredar atributos de otra clase",
			"Crear muchos objetos iguales",
			"Ocultar los datos internos y exponerlos solo con métodos",
			"Ejecutar el mismo método en distintas clases"
		],
		"correcta": 2
	},
	{
		"tipo": "multiple",
		"pregunta": "En el código: var _vida = 100 — ¿por qué el guion bajo?",
		"opciones": [
			"Es un error de sintaxis",
			"Indica que la variable es privada (encapsulamiento)",
			"Significa que es una constante",
			"Es solo una convención visual sin significado"
		],
		"correcta": 1
	},
	{
		"tipo": "drag",
		"pregunta": "Arrastra cada concepto a su definición correcta:",
		"pares": [
			{"concepto": "Clase",  "definicion": "Plantilla o molde"},
			{"concepto": "Objeto", "definicion": "Instancia concreta"},
		]
	},
	{
		"tipo": "drag",
		"pregunta": "Arrastra cada concepto a su definición correcta:",
		"pares": [
			{"concepto": "Atributo", "definicion": "Dato del objeto"},
			{"concepto": "Método",   "definicion": "Acción del objeto"},
		]
	},
	{
		"tipo": "drag",
		"pregunta": "Arrastra cada concepto a su definición correcta:",
		"pares": [
			{"concepto": "_variable",    "definicion": "Encapsulada / privada"},
			{"concepto": "get_health()", "definicion": "Getter público"},
		]
	},
]

# ── Nodos ─────────────────────────────────────────────────────────────────────
@onready var _panel          : Panel         = $Panel
@onready var _pregunta_label : Label         = $Panel/PreguntaLabel
@onready var _tipo_a         : VBoxContainer = $Panel/TipoA
@onready var _tipo_b         : GridContainer = $Panel/TipoB
@onready var _feedback_label : Label         = $Panel/FeedbackLabel
@onready var _cerrar_btn     : Button        = $Panel/CerrarBtn
@onready var _opciones_btns  : Array[Button] = [
	$Panel/TipoA/Opcion0,
	$Panel/TipoA/Opcion1,
	$Panel/TipoA/Opcion2,
	$Panel/TipoA/Opcion3,
]

# ── Estado ────────────────────────────────────────────────────────────────────
var _pregunta_actual    : Dictionary = {}
var _pregunta_precargada: Dictionary = {}
var _respondida         := false
var _cargando           := false

# Drag & drop
var _drag_concepto  : String     = ""
var _zonas          : Array      = []
var _zona_asignada  : Dictionary = {}

# ── Ciclo de vida ─────────────────────────────────────────────────────────────
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_centrar_panel()
	_cerrar_btn.pressed.connect(_cerrar)
	for i in _opciones_btns.size():
		_opciones_btns[i].pressed.connect(_on_opcion_presionada.bind(i))

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_cerrar()

# ── API pública ───────────────────────────────────────────────────────────────
func abrir() -> void:
	_respondida = false
	visible = true
	get_tree().paused = true

	if not _pregunta_precargada.is_empty():
		# Mostrar instantáneamente la pregunta precargada
		_pregunta_actual = _pregunta_precargada
		_pregunta_precargada = {}
		_feedback_label.text = ""
		_mostrar_pregunta(_pregunta_actual)
		_precargar_siguiente()
		return

	# Sin precarga: pedir a Gemini
	_cargando = true
	_feedback_label.modulate = Color.WHITE
	_tipo_a.visible = false
	_tipo_b.visible = false
	_pregunta_label.text = ""
	_animar_carga()
	_conectar_gemini()
	GeminiService.solicitar_pregunta("multiple" if randf() > 0.4 else "drag")

# ── Gemini ────────────────────────────────────────────────────────────────────
func _conectar_gemini() -> void:
	if not GeminiService.pregunta_lista.is_connected(_on_pregunta_lista):
		GeminiService.pregunta_lista.connect(_on_pregunta_lista)
	if not GeminiService.error_api.is_connected(_on_error_api):
		GeminiService.error_api.connect(_on_error_api)

func _desconectar_gemini() -> void:
	if GeminiService.pregunta_lista.is_connected(_on_pregunta_lista):
		GeminiService.pregunta_lista.disconnect(_on_pregunta_lista)
	if GeminiService.error_api.is_connected(_on_error_api):
		GeminiService.error_api.disconnect(_on_error_api)

func _on_pregunta_lista(datos: Dictionary) -> void:
	_desconectar_gemini()
	_cargando = false
	_feedback_label.text = ""
	_pregunta_actual = datos
	_mostrar_pregunta(datos)
	_precargar_siguiente()

func _on_error_api(mensaje: String) -> void:
	_desconectar_gemini()
	_cargando = false
	push_warning("Gemini falló: %s — usando banco local" % mensaje)
	_pregunta_actual = PREGUNTAS[randi() % PREGUNTAS.size()]
	_feedback_label.text = ""
	_mostrar_pregunta(_pregunta_actual)

func _precargar_siguiente() -> void:
	var tipo := "multiple" if randf() > 0.4 else "drag"
	GeminiService.pregunta_lista.connect(_on_precarga_lista, CONNECT_ONE_SHOT)
	GeminiService.solicitar_pregunta(tipo)

func _on_precarga_lista(datos: Dictionary) -> void:
	_pregunta_precargada = datos

# ── Mostrar pregunta ──────────────────────────────────────────────────────────
func _mostrar_pregunta(p: Dictionary) -> void:
	_pregunta_label.text = p["pregunta"]
	if p["tipo"] == "multiple":
		_setup_multiple(p)
	else:
		_setup_drag(p)

func _setup_multiple(p: Dictionary) -> void:
	_tipo_a.visible = true
	_tipo_b.visible = false
	for i in _opciones_btns.size():
		_opciones_btns[i].text     = p["opciones"][i]
		_opciones_btns[i].disabled = false
		_opciones_btns[i].modulate = Color.WHITE

func _setup_drag(p: Dictionary) -> void:
	_tipo_a.visible = false
	_tipo_b.visible = true
	_zona_asignada.clear()
	_drag_concepto = ""
	_zonas = []

	for child in _tipo_b.get_children():
		child.queue_free()

	var pares: Array = p["pares"]
	var conceptos := pares.map(func(par): return par["concepto"])
	conceptos.shuffle()

	# Fila 1 — botones de conceptos
	for c in conceptos:
		var btn := Button.new()
		btn.text = c
		btn.custom_minimum_size = Vector2(160, 40)
		btn.pressed.connect(_on_concepto_presionado.bind(c, btn))
		_tipo_b.add_child(btn)

	# Fila 2 — zonas de drop
	for i in pares.size():
		var zona := Panel.new()
		zona.custom_minimum_size = Vector2(160, 40)
		var lbl := Label.new()
		lbl.text = pares[i]["definicion"]
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
		lbl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		zona.add_child(lbl)
		zona.gui_input.connect(_on_zona_input.bind(i, pares[i]["concepto"]))
		_tipo_b.add_child(zona)
		_zonas.append(zona)

# ── Opción múltiple ───────────────────────────────────────────────────────────
func _on_opcion_presionada(idx: int) -> void:
	if _respondida:
		return
	_respondida = true
	if idx == _pregunta_actual["correcta"]:
		_exito(_opciones_btns[idx])
	else:
		_opciones_btns[idx].modulate = Color(1, 0.3, 0.3)
		_opciones_btns[_pregunta_actual["correcta"]].modulate = Color(0.3, 1, 0.3)
		_fallo()

# ── Drag & drop ───────────────────────────────────────────────────────────────
func _on_concepto_presionado(concepto: String, btn: Button) -> void:
	_drag_concepto = concepto
	for child in _tipo_b.get_children():
		if child is Button:
			child.modulate = Color.WHITE
	btn.modulate = Color(0.5, 1, 1)

func _on_zona_input(event: InputEvent, zona_idx: int, _concepto_correcto: String) -> void:
	if not (event is InputEventMouseButton and event.pressed and _drag_concepto != ""):
		return
	_zona_asignada[zona_idx] = _drag_concepto
	var lbl : Label = _zonas[zona_idx].get_child(0)
	lbl.text = "%s\n──────\n%s" % [_drag_concepto, lbl.text.split("\n")[0]]
	_drag_concepto = ""
	if _zona_asignada.size() == _pregunta_actual["pares"].size():
		_verificar_drag()

func _verificar_drag() -> void:
	if _respondida:
		return
	_respondida = true
	var pares: Array = _pregunta_actual["pares"]
	for i in pares.size():
		if _zona_asignada.get(i, "") != pares[i]["concepto"]:
			_fallo()
			return
	_exito(null)

# ── Resultado ─────────────────────────────────────────────────────────────────
func _exito(btn: Button) -> void:
	_feedback_label.text     = "✅ ¡Correcto! La puerta se abre."
	_feedback_label.modulate = Color(0.3, 1, 0.3)
	if btn:
		btn.modulate = Color(0.3, 1, 0.3)
	await get_tree().create_timer(1.5).timeout
	respuesta_correcta.emit()
	_cerrar()

func _fallo() -> void:
	_feedback_label.text     = "❌ Incorrecto. Intenta de nuevo."
	_feedback_label.modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(1.5).timeout
	_respondida = false
	_feedback_label.text = ""
	for btn in _opciones_btns:
		btn.modulate = Color.WHITE
		btn.disabled = false

# ── Helpers ───────────────────────────────────────────────────────────────────
func _centrar_panel() -> void:
	var screen_size := get_viewport().get_visible_rect().size
	_panel.position = (screen_size - PANEL_SIZE) / 2
	_panel.size     = PANEL_SIZE

func _animar_carga() -> void:
	var puntos := 0
	while _cargando:
		puntos = (puntos + 1) % 4
		_feedback_label.text = "⏳ Generando pregunta" + ".".repeat(puntos)
		await get_tree().create_timer(0.4).timeout

func _cerrar() -> void:
	visible = false
	get_tree().paused = false
	terminal_cerrada.emit()
