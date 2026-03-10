# mundo_inicial.gd
# Nodo raíz: Node2D (la escena Mundo.tscn)
# Controla el progreso del mundo inicial:
# 1. Terminal resuelta
# 2. Bugs eliminados
# 3. Puerta se abre al completar todo
#
# En el editor conecta las señales:
# - terminal_poo.resuelto         → _on_terminal_resuelta()
# - cada Bug.tree_exited          → _on_bug_eliminado()

extends Node2D

# ── Configura cuántos bugs debe eliminar el jugador ───────────────────────────
const BUGS_REQUERIDOS := 2

# ── Nodos — ajusta las rutas según tu escena ─────────────────────────────────
@onready var puerta         = $Puerta          # el nodo Puerta
@onready var terminal       = $TerminalPOO     # la terminal del mundo
@onready var npc            = $NPC             # el NPC tutorial
											   # si es Autoload usa DialogoSistema directamente

# ── Estado ────────────────────────────────────────────────────────────────────
var _terminal_resuelta := false
var _bugs_eliminados   := 0

# ── Ciclo de vida ─────────────────────────────────────────────────────────────
func _ready() -> void:
	# La puerta empieza invisible e intransitable
	puerta.visible = false
	puerta.get_node("CollisionShape2D").set_deferred("disabled", true)

	# Diálogo de bienvenida al entrar a la sala
	await get_tree().create_timer(0.8).timeout
	DialogoSistema.mostrar("sala_inicio")

	# Conectar terminal
	if terminal:
		terminal.resuelto.connect(_on_terminal_resuelta)

# ── Callbacks ─────────────────────────────────────────────────────────────────
func _on_terminal_resuelta() -> void:
	_terminal_resuelta = true
	DialogoSistema.mostrar("terminal_resuelta")
	_verificar_progreso()

func _on_bug_eliminado() -> void:
	_bugs_eliminados += 1
	if _bugs_eliminados == 1:
		DialogoSistema.mostrar("bug_eliminado")
	_verificar_progreso()

# ── Lógica de desbloqueo ──────────────────────────────────────────────────────
func _verificar_progreso() -> void:
	if _terminal_resuelta and _bugs_eliminados >= BUGS_REQUERIDOS:
		_abrir_puerta()

func _abrir_puerta() -> void:
	# Animación de aparición de la puerta
	puerta.visible = true
	puerta.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(puerta, "modulate:a", 1.0, 0.8)
	await tween.finished
	puerta.get_node("CollisionShape2D").set_deferred("disabled", false)

	# Diálogo especial al abrirse
	DialogoSistema.mostrar_texto(
		"La estructura está reorganizada.\nEl acceso al laberinto ha sido desbloqueado."
	)
