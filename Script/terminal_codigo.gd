# terminal_codigo.gd
# Nodo: CanvasLayer  (hijo TerminalCodigo dentro de terminalcodigo_poo.tscn)
#
# ✓ NO pausa el juego — el mundo sigue corriendo
# ✓ Bloquea solo el movimiento del jugador (player.bloqueado = true)
# ✓ Concepto corto + ejemplo + ejercicio en UNA sola pantalla
# ✓ [H] muestra/oculta pista en esquina superior derecha
# ✓ [Esc] cierra  |  [Enter] valida
#
# Nodos de terminalcodigo_poo.tscn que usa este script:
#   $Panel/TituloLabel
#   $Panel/FaseExplicacion/ConceptoLabel    (Label)
#   $Panel/FaseExplicacion/ExplicacionLabel (RichTextLabel)
#   $Panel/FaseEjercicio/InstruccionLabel   (Label)
#   $Panel/FaseEjercicio/CodigoLabel        (RichTextLabel)
#   $Panel/FaseEjercicio/InputField         (LineEdit)
#   $Panel/FaseEjercicio/ValidarBtn         (Button)
#   $Panel/FaseEjercicio/FeedbackLabel      (Label)
#   $Panel/CerrarBtn                        (Button)

extends CanvasLayer

signal respuesta_correcta
signal respuesta_incorrecta

const PANEL_PISTA_SIZE := Vector2(280, 190)
const MARGEN           := 16.0

const LECCIONES := [
	# ── Terminal 1: Clases ───────────────────────────────────────────────────
	{
		"titulo":      "> TERMINAL_01 — Clases",
		"concepto":    "Una CLASE es una plantilla que define atributos y métodos.\nComo el plano de un edificio: describe su estructura.",
		"ejemplo":
			"[color=cyan]class[/color] [color=yellow]Personaje[/color] {\n"
			+ "    [color=cyan]public string[/color] nombre;\n"
			+ "    [color=cyan]public int[/color] vida;\n"
			+ "}",
		"instruccion": "Completa: define la clase Vehiculo",
		"codigo":
			"[color=yellow]___[/color] Vehiculo {\n"
			+ "    public string marca;\n"
			+ "}",
		"respuesta":    "class",
		"pista_titulo": "💡 Pista",
		"pista":        "Palabra clave en C# para definir una clase: [b]class[/b]",
	},
	# ── Terminal 2: Objetos ──────────────────────────────────────────────────
	{
		"titulo":      "> TERMINAL_02 — Objetos",
		"concepto":    "Un OBJETO es una instancia concreta de una clase.\nSi la clase es el plano, el objeto es el edificio construido.",
		"ejemplo":
			"[color=yellow]Personaje[/color] heroe = [color=cyan]new[/color] [color=yellow]Personaje[/color]();\n"
			+ "heroe.nombre = [color=green]\"Compilador\"[/color];\n"
			+ "heroe.vida   = [color=orange]100[/color];",
		"instruccion": "Completa: crea un objeto de la clase Vehiculo",
		"codigo":      "Vehiculo miAuto = [color=yellow]___[/color] Vehiculo();",
		"respuesta":    "new",
		"pista_titulo": "💡 Pista",
		"pista":        "Para crear un objeto en C# se usa: [b]new[/b]",
	},
	# ── Terminal 3: Atributos ────────────────────────────────────────────────
	{
		"titulo":      "> TERMINAL_03 — Atributos",
		"concepto":    "Los ATRIBUTOS son las variables de una clase.\nUsar [b]private[/b] los protege (solo accesibles desde dentro).",
		"ejemplo":
			"[color=cyan]class[/color] [color=yellow]Personaje[/color] {\n"
			+ "    [color=red]private int[/color] _vida;     [color=gray]// privado[/color]\n"
			+ "    [color=cyan]public string[/color] nombre; [color=gray]// público[/color]\n"
			+ "}",
		"instruccion": "Completa: declara el atributo privado _combustible",
		"codigo":
			"class Vehiculo {\n"
			+ "    [color=yellow]___[/color] float _combustible;\n"
			+ "}",
		"respuesta":    "private",
		"pista_titulo": "💡 Pista",
		"pista":        "Modificador para ocultar un atributo: [b]private[/b]",
	},
	# ── Terminal 4: Métodos ──────────────────────────────────────────────────
	{
		"titulo":      "> TERMINAL_04 — Métodos",
		"concepto":    "Los MÉTODOS son las acciones que puede hacer un objeto.\nUn método que no devuelve nada usa el tipo [b]void[/b].",
		"ejemplo":
			"[color=cyan]class[/color] [color=yellow]Personaje[/color] {\n"
			+ "    [color=cyan]public void[/color] Atacar() {\n"
			+ "        Console.WriteLine([color=green]\"¡Ataque!\"[/color]);\n"
			+ "    }\n"
			+ "}",
		"instruccion": "Completa: el tipo de retorno del método Avanzar",
		"codigo":
			"public [color=yellow]___[/color] Avanzar() {\n"
			+ "    Console.WriteLine(\"Avanzando...\");\n"
			+ "}",
		"respuesta":    "void",
		"pista_titulo": "💡 Pista",
		"pista":        "Tipo de retorno cuando un método no devuelve nada: [b]void[/b]",
	},
]

# ── Nodos existentes ──────────────────────────────────────────────────────────
@onready var _titulo_label   : Label         = $Panel/TituloLabel
@onready var _fase_exp       : VBoxContainer = $Panel/FaseExplicacion
@onready var _concepto_label : Label         = $Panel/FaseExplicacion/ConceptoLabel
@onready var _ejemplo_label  : RichTextLabel = $Panel/FaseExplicacion/ExplicacionLabel
@onready var _instruccion    : Label         = $Panel/FaseEjercicio/InstruccionLabel
@onready var _codigo         : RichTextLabel = $Panel/FaseEjercicio/CodigoLabel
@onready var _input_field    : LineEdit      = $Panel/FaseEjercicio/InputField
@onready var _validar_btn    : Button        = $Panel/FaseEjercicio/ValidarBtn
@onready var _feedback       : Label         = $Panel/FaseEjercicio/FeedbackLabel
@onready var _cerrar_btn     : Button        = $Panel/CerrarBtn

# ── Nodo opcional para pista ──────────────────────────────────────────────────
@onready var _panel_pista     = get_node_or_null("Panel/PanelPista")
@onready var _pista_titulo    = get_node_or_null("Panel/PanelPista/TituloLabel")
@onready var _pista_contenido = get_node_or_null("Panel/PanelPista/ContenidoLabel")

@export var leccion_id : int = 0

var _leccion       : Dictionary = {}
var _resuelta      := false
var _validando     := false
var _pista_visible := false
var _jugador       : CharacterBody2D = null  # referencia cacheada al player
# Acciones de movimiento cuyos eventos WASD se eliminan temporalmente al abrir
# Teclas que se deben remover de TODAS las acciones al escribir en la terminal
# KEY_A=65 KEY_D=68 KEY_W=87 KEY_S=83 KEY_E=69
const _KEYCODES_TEXTO := [KEY_A, KEY_D, KEY_W, KEY_S, KEY_E]
var _eventos_removidos : Array = []  # Array de {accion, evento}

# ── Ciclo de vida ─────────────────────────────────────────────────────────────
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	# Ocultar botón "Entendido → Practicar" si existe
	var continuar_btn = get_node_or_null("Panel/FaseExplicacion/ContinuarBtn")
	if continuar_btn:
		continuar_btn.visible = false

	# Mostrar ambas fases juntas desde el inicio
	if _fase_exp:
		_fase_exp.visible = true

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

# ── Buscar jugador en el árbol ────────────────────────────────────────────────
func _obtener_jugador() -> CharacterBody2D:
	if _jugador and is_instance_valid(_jugador):
		return _jugador
	# Buscar por grupo "jugador" (definido en Player.tscn)
	var jugadores := get_tree().get_nodes_in_group("jugador")
	if jugadores.is_empty():
		# Fallback: buscar por grupo "Player"
		jugadores = get_tree().get_nodes_in_group("Player")
	if not jugadores.is_empty():
		_jugador = jugadores[0]
	return _jugador

# ── Quitar/restaurar eventos WASD del InputMap ───────────────────────────────
func _quitar_wasd() -> void:
	# Recorre TODAS las acciones del InputMap y elimina cualquier evento
	# que use las teclas de texto (A, W, S, D, E)
	_eventos_removidos.clear()
	var todas_acciones := InputMap.get_actions()
	for accion in todas_acciones:
		var events := InputMap.action_get_events(accion)
		for ev in events:
			if ev is InputEventKey:
				var kc : int = ev.physical_keycode if ev.physical_keycode != 0 else ev.keycode
				if kc in _KEYCODES_TEXTO:
					InputMap.action_erase_event(accion, ev)
					_eventos_removidos.append({"accion": accion, "evento": ev})

func _restaurar_wasd() -> void:
	for entrada in _eventos_removidos:
		InputMap.action_add_event(entrada["accion"], entrada["evento"])
	_eventos_removidos.clear()

func _bloquear_jugador(bloquear: bool) -> void:
	var p := _obtener_jugador()
	if not p:
		return
	if bloquear:
		p.velocity = Vector2.ZERO
		p.move_and_slide()
		p.set_physics_process(false)
		p.set_process_unhandled_input(false)
	else:
		p.set_physics_process(true)
		p.set_process_unhandled_input(true)

# ── API pública ───────────────────────────────────────────────────────────────
func abrir() -> void:
	if _resuelta:
		return
	_leccion = LECCIONES[clamp(leccion_id, 0, LECCIONES.size() - 1)]
	_poblar_ui()
	visible = true
	_bloquear_jugador(true)
	_quitar_wasd()            # ← WASD disponibles para escribir
	_input_field.grab_focus()

func _poblar_ui() -> void:
	_titulo_label.text            = _leccion["titulo"]
	_concepto_label.text          = _leccion["concepto"]
	_ejemplo_label.text           = "[font_size=12]" + _leccion["ejemplo"] + "[/font_size]"
	_instruccion.text             = _leccion["instruccion"]
	_codigo.text                  = "[font_size=13]" + _leccion["codigo"] + "[/font_size]"
	_input_field.text             = ""
	_input_field.placeholder_text = "Escribe aquí...   [H] pista   [Esc] cerrar"
	_feedback.text                = ""
	_validar_btn.disabled         = false
	_input_field.editable         = true

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
		+ "Responde SOLO con JSON sin texto extra ni markdown: "
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
	contenido = _extraer_json_str(contenido)
	var datos = JSON.parse_string(contenido)
	if not datos or not datos.has("correcto"):
		_validar_local(respuesta)
		return

	_aplicar_resultado(datos["correcto"], datos.get("explicacion", ""))

func _extraer_json_str(texto: String) -> String:
	var limpio := texto.strip_edges().replace("```json", "").replace("```", "").strip_edges()
	var inicio := limpio.find("{")
	var fin    := limpio.rfind("}")
	if inicio != -1 and fin > inicio:
		return limpio.substr(inicio, fin - inicio + 1)
	return limpio

func _validar_local(respuesta: String) -> void:
	var esperada := (_leccion["respuesta"] as String).strip_edges().to_lower()
	var dada     := respuesta.strip_edges().to_lower()
	var correcto := (dada == esperada)
	var msg : String = "✓ ¡Correcto!" if correcto else "✗ Incorrecto.   Pulsa [H] para ver la pista."
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
	_restaurar_wasd()          # ← restaurar movimiento WASD
	_bloquear_jugador(false)
	if _panel_pista:
		_panel_pista.visible = false
