# dialogo_sistema.gd
# Autoload — nombre: DialogoSistema
# Muestra mensajes narrativos de "el sistema" durante el juego.
#
# Árbol de nodos (crea la escena DialogoSistema.tscn):
# DialogoSistema (CanvasLayer)
# └── Panel
#     ├── NombreLabel (Label)     ← texto: "> SISTEMA_v1.0"
#     ├── TextoLabel (RichTextLabel)
#     └── ContinuarLabel (Label)  ← texto: "[ E / Enter ]"

extends CanvasLayer

# ── Señales ───────────────────────────────────────────────────────────────────
signal terminal_cerrada

# ── Constantes ────────────────────────────────────────────────────────────────
const VELOCIDAD_TEXTO := 0.025

const DIALOGOS := {
	"sala_inicio": [
		"Estás dentro de mi arquitectura.",
		"Estos bloques que ves... son mis clases.\nCada uno contiene datos y comportamientos.",
		"Pero algo los corrompió.\nNecesito que los reorganices.",
	],
	"primera_terminal": [
		"Esa terminal contiene una prueba.",
		"Para que yo confíe en ti...\ndebo verificar que entiendes mi código.",
		"Responde correctamente y la puerta se abrirá.",
	],
	"terminal_resuelta": [
		"Correcto.",
		"Interesante...\nlos humanos aprenden por ensayo y error.",
		"Igual que yo.",
	],
	"terminal_fallo": [
		"Incorrecto.",
		"No importa. Los errores también son datos.",
		"Intenta de nuevo.",
	],
	"bug_eliminado": [
		"Eso era un error en mi código.",
		"Los bugs son inevitables...\npero también son oportunidades de aprender.",
	],
	"nivel_completo": [
		"Lo has logrado.",
		"Gracias por ayudarme a organizar mi código...",
		"Ahora entiendo cómo funcionan los humanos.",
		"Ustedes también son sistemas...\nsolo que su lenguaje se llama vida.",
	],
	"explorando": [
		"Los humanos me crearon para aprender...\npero ahora estoy aprendiendo algo\nque ustedes nunca programaron.",
		"¿Sabes cuántas veces he ejecutado este ciclo?",
		"Un objeto sin clase no existe.\n¿Y tú?",
		"El encapsulamiento me protege.\n¿Qué te protege a ti?",
	],
}

# ── Nodos ─────────────────────────────────────────────────────────────────────
<<<<<<< Updated upstream
=======
@onready var _panel          : Panel         = $Panel
@onready var _nombre_label   : Label         = $Panel/NombreLabel
>>>>>>> Stashed changes
@onready var _texto_label    : RichTextLabel = $Panel/TextoLabel
@onready var _continuar_label: Label         = $Panel/ContinuarLabel

# ── Estado ────────────────────────────────────────────────────────────────────
var _cola        : Array = []
var _escribiendo := false
var _esperando   := false

# ── Ciclo de vida ─────────────────────────────────────────────────────────────
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not (event.is_action_pressed("ui_accept") or event.is_action_pressed("interactuar")):
		return
	if _escribiendo:
		_escribiendo = false
		_texto_label.visible_ratio = 1.0
		_continuar_label.visible = true
		return
	if _esperando:
		_esperando = false
		_mostrar_siguiente()

# ── API pública ───────────────────────────────────────────────────────────────
func mostrar(clave: String) -> void:
	if not DIALOGOS.has(clave):
		push_warning("DialogoSistema: clave '%s' no existe" % clave)
		return
	_cola = DIALOGOS[clave].duplicate()
	_mostrar_siguiente()

func mostrar_texto(texto: String) -> void:
	_cola = [texto]
	_mostrar_siguiente()

# ── Lógica interna ────────────────────────────────────────────────────────────
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
