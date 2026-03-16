# mundo_inicial.gd
# Nodo raíz: Node2D (la escena Mundo.tscn)

extends Node2D

# ── Pon en 0 si aún no tienes bugs en la escena ──────────────────────────────
const BUGS_REQUERIDOS := 0

@onready var puerta   = $Puerta
@onready var terminal = $TerminalPOO

# ── Estado ────────────────────────────────────────────────────────────────────
var _terminal_resuelta := false
var _bugs_eliminados   := 0

# ── Ciclo de vida ─────────────────────────────────────────────────────────────
func _ready() -> void:
	print("=== MUNDO INICIAL READY ===")
	print("puerta: ", puerta)
	print("terminal: ", terminal)
	
	if terminal:
		terminal.resuelto.connect(_on_terminal_resuelta)
		print("Terminal conectada OK")
	else:
		push_error("mundo_inicial: no se encontró TerminalPOO")

	# Diálogo de bienvenida
	await get_tree().create_timer(0.8).timeout
	DialogoSistema.mostrar("sala_inicio")

# ── Callbacks ─────────────────────────────────────────────────────────────────
func _on_terminal_resuelta() -> void:
	print("=== _on_terminal_resuelta LLAMADO ===")
	_terminal_resuelta = true
	_verificar_progreso()


func _on_bug_eliminado() -> void:
	_bugs_eliminados += 1
	if _bugs_eliminados == 1:
		DialogoSistema.mostrar("bug_eliminado")
	_verificar_progreso()

# ── Lógica de desbloqueo ──────────────────────────────────────────────────────
func _verificar_progreso() -> void:
	print("Verificando: terminal=%s bugs=%d/%d" % [_terminal_resuelta, _bugs_eliminados, BUGS_REQUERIDOS])
	if _terminal_resuelta and _bugs_eliminados >= BUGS_REQUERIDOS:
		print("=== ABRIENDO PUERTA ===")
		_abrir_puerta()

func _abrir_puerta() -> void:
	# puerta.abrir() maneja visibilidad, fade y colisión internamente
	print("puerta.abrir() llamado")
	puerta.abrir()
	DialogoSistema.mostrar_texto(
		"La estructura está reorganizada.\nEl acceso al laberinto ha sido desbloqueado."
	)
