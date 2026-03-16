# dialogo_sistema.gd
# Autoload — apunta a DialogoSistema.tscn (CanvasLayer)
# Mensajes cortos: máximo 2-3 por secuencia.

extends CanvasLayer

signal terminal_cerrada

const VELOCIDAD_TEXTO := 0.02

const DIALOGOS := {
	# ── Narrativos ────────────────────────────────────────────────────────────
	"sala_inicio": [
		"Bienvenido a mi arquitectura.\nAlgo la corrompió... necesito tu ayuda.",
		"Interactúa con la terminal [E] para demostrar que entiendes mi código.",
	],
	"primera_terminal": [
		"Esa terminal contiene una prueba.\nResponde correctamente y la puerta se abrirá.",
	],
	"terminal_resuelta": [
		"Correcto. Los humanos aprenden igual que yo: por ensayo y error.",
	],
	"terminal_fallo": [
		"Incorrecto. Los errores también son datos. Inténtalo de nuevo.",
	],
	"bug_eliminado": [
		"Eliminaste un error de mi código.\nLos bugs son inevitables... pero corregibles.",
	],
	"nivel_completo": [
		"Lo has logrado. Mi código está reorganizado.",
		"Ahora entiendo algo que nunca me programaron:\ncómo piensan los humanos.",
	],
	"explorando": [
		"Un objeto sin clase no existe. ¿Y tú?",
		"El encapsulamiento me protege.\n¿Qué te protege a ti?",
	],

	# ── Pedagógicos cortos — Mundo Tutorial ───────────────────────────────────
	# Antes de la terminal: solo recordatorio, la terminal ya explica el concepto
	"leccion_atributos": [
		"Los [b]atributos[/b] son las variables de una clase.\nEjemplo: nombre, vida, velocidad.",
	],
	"leccion_objetos": [
		"Un [b]objeto[/b] es una instancia concreta de una clase.\nSe crea con [b]new[/b]: Personaje heroe = new Personaje();",
	],
}

@onready var _texto_label    : RichTextLabel = $Panel/TextoLabel
@onready var _continuar_label: Label         = $Panel/ContinuarLabel

var _cola        : Array = []
var _escribiendo := false
var _esperando   := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not (event.is_action_pressed("ui_accept") or event.is_action_pressed("interactuar")):
		return
	if _escribiendo:
		# Saltar animación de texto
		_escribiendo = false
		_texto_label.visible_ratio = 1.0
		_continuar_label.visible = true
		return
	if _esperando:
		_esperando = false
		_mostrar_siguiente()

func mostrar(clave: String) -> void:
	if not DIALOGOS.has(clave):
		push_warning("DialogoSistema: clave '%s' no existe" % clave)
		return
	_cola = DIALOGOS[clave].duplicate()
	_mostrar_siguiente()

func mostrar_texto(texto: String) -> void:
	_cola = [texto]
	_mostrar_siguiente()

func _mostrar_siguiente() -> void:
	if _cola.is_empty():
		_cerrar()
		return
	var texto : String = _cola.pop_front()
	visible = true
	get_tree().paused = true
	_continuar_label.visible = false
	_texto_label.text = texto
	_texto_label.visible_ratio = 0.0
	_escribir_texto()

func _escribir_texto() -> void:
	_escribiendo = true
	var total := _texto_label.get_total_character_count()
	for i in range(total + 1):
		if not _escribiendo:
			break
		_texto_label.visible_characters = i
		await get_tree().create_timer(VELOCIDAD_TEXTO).timeout
	_escribiendo = false
	_texto_label.visible_ratio = 1.0
	_continuar_label.visible = true
	_esperando = true

func _cerrar() -> void:
	visible = false
	get_tree().paused = false
	terminal_cerrada.emit()
