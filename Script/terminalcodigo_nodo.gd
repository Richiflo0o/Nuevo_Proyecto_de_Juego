# terminalcodigo_nodo.gd
# Nodo: StaticBody2D  (el objeto físico de la terminal en el mundo)
# Árbol requerido:
# TerminalNodo (StaticBody2D)  ← este script
# ├── Sprite2D                 ← sprite normal/resuelto
# ├── CollisionShape2D
# ├── IndicadorLabel (Label)   ← "[E] Estudiar"
# └── TerminalCodigo (CanvasLayer) ← terminal_codigo.gd, @export leccion_id

extends StaticBody2D

signal resuelta(id: String)

# El laberinto_manager conecta esta señal para saber cuántas se resolvieron
@export var leccion_id  : int    = 0   # 0=Clases 1=Objetos 2=Atributos 3=Métodos
@export var terminal_id : String = "T1"

@onready var _sprite    : Sprite2D   = $Sprite2D
@onready var _indicador             = $TerminalCodigo/IndicadorLabel  # puede ser null
@onready var _terminal  : CanvasLayer = $TerminalCodigo

var _resuelta := false

func _ready() -> void:
	# Pasar el leccion_id al CanvasLayer hijo
	if _terminal and _terminal.has_method("abrir"):
		_terminal.leccion_id = leccion_id
		_terminal.respuesta_correcta.connect(_on_resuelta)

	if _indicador:
		_indicador.visible = false

func interactuar() -> void:
	if _resuelta or not _terminal:
		return
	_terminal.abrir()

# ── Zona de detección de proximidad ──────────────────────────────────────────
# Conecta body_entered / body_exited de un Area2D hijo llamado "ZonaInteraccion"
func _on_zona_entered(body: Node2D) -> void:
	if body.is_in_group("jugador") and not _resuelta:
		if _indicador:
			_indicador.visible = true

func _on_zona_exited(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		if _indicador:
			_indicador.visible = false

# ── Callback cuando se resuelve ───────────────────────────────────────────────
func _on_resuelta() -> void:
	_resuelta = true
	# Cambiar color del sprite a verde para indicar que está resuelta
	if _sprite:
		_sprite.modulate = Color(0.3, 1.0, 0.4)
	if _indicador:
		_indicador.visible = false
	GameManager.registrar_terminal(terminal_id)
	resuelta.emit(terminal_id)
