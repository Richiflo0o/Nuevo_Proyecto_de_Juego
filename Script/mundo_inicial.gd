# mundo_inicial.gd
# Nodo raíz: Node2D — Mundo.tscn
# Flujo: bienvenida rápida → jugador explora → interactúa con terminal → puerta

extends Node2D

const BUGS_REQUERIDOS := 0

@onready var puerta   = $Puerta
@onready var terminal = $TerminalPOO

var _terminal_resuelta := false
var _bugs_eliminados   := 0

func _ready() -> void:
	print("=== MUNDO INICIAL READY ===")

	if terminal:
		terminal.resuelto.connect(_on_terminal_resuelta)
	else:
		push_error("mundo_inicial: no se encontró TerminalPOO")

	# Solo 1 mensaje de bienvenida, directo
	await get_tree().create_timer(0.8).timeout
	DialogoSistema.mostrar("sala_inicio")

func _on_terminal_resuelta() -> void:
	_terminal_resuelta = true
	_verificar_progreso()

func _on_bug_eliminado() -> void:
	_bugs_eliminados += 1
	if _bugs_eliminados == 1:
		DialogoSistema.mostrar("bug_eliminado")
	_verificar_progreso()

func _verificar_progreso() -> void:
	if _terminal_resuelta and _bugs_eliminados >= BUGS_REQUERIDOS:
		_abrir_puerta()

func _abrir_puerta() -> void:
	puerta.abrir()
	DialogoSistema.mostrar_texto("Acceso al laberinto desbloqueado.")
