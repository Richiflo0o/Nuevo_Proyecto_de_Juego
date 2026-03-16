# laberinto_manager.gd
# Nodo raíz de laberinto.tscn (Node2D)
# Gestiona el progreso: espera que se resuelvan las 4 terminales y abre la puerta.
#
# Árbol requerido en laberinto.tscn:
# Laberinto (Node2D)        ← este script
# ├── TileMapLayer
# ├── Player
# ├── Terminal1 (instancia de terminalcodigo_poo.tscn) ← script: terminalcodigo_nodo.gd, leccion_id=0, terminal_id="T1"
# ├── Terminal2 (instancia de terminalcodigo_poo.tscn) ← script: terminalcodigo_nodo.gd, leccion_id=1, terminal_id="T2"
# ├── Terminal3 (instancia de terminalcodigo_poo.tscn) ← script: terminalcodigo_nodo.gd, leccion_id=2, terminal_id="T3"
# ├── Terminal4 (instancia de terminalcodigo_poo.tscn) ← script: terminalcodigo_nodo.gd, leccion_id=3, terminal_id="T4"
# └── Puerta (instancia de puerta.tscn)               ← puerta.gd (sin cambios)

extends Node2D

const TERMINALES_REQUERIDAS := 4

@onready var _terminal1 = $Terminal1
@onready var _terminal2 = $Terminal2
@onready var _terminal3 = $Terminal3
@onready var _terminal4 = $Terminal4
@onready var _puerta    = $Puerta      # ← instancia de puerta.tscn, ya tiene abrir() e interactuar()

var _resueltas := 0

func _ready() -> void:
	print("=== LABERINTO MANAGER READY ===")

	# Conectar señal 'resuelta' de cada terminal
	for t in [_terminal1, _terminal2, _terminal3, _terminal4]:
		if t and t.has_signal("resuelta"):
			t.resuelta.connect(_on_terminal_resuelta)
		else:
			push_error("laberinto_manager: terminal no encontrada o sin señal 'resuelta'")

	if not _puerta:
		push_error("laberinto_manager: no se encontró nodo 'Puerta'")

	# Diálogo de bienvenida
	await get_tree().create_timer(1.0).timeout
	DialogoSistema.mostrar_texto(
		"Has llegado al laberinto de código.\n"
		+ "Resuelve las [b]4 terminales[/b] para abrir la salida."
	)

func _on_terminal_resuelta(_id: String) -> void:
	_resueltas += 1
	print("Terminal resuelta %d/%d" % [_resueltas, TERMINALES_REQUERIDAS])

	match _resueltas:
		1:
			DialogoSistema.mostrar_texto(
				"Primera terminal resuelta.\nFaltan %d más." % (TERMINALES_REQUERIDAS - _resueltas)
			)
		2:
			DialogoSistema.mostrar_texto(
				"¡Vas a la mitad!\nFaltan %d terminales." % (TERMINALES_REQUERIDAS - _resueltas)
			)
		3:
			DialogoSistema.mostrar_texto("Solo falta una terminal más...")
		4:
			_abrir_puerta()

func _abrir_puerta() -> void:
	print("=== ABRIENDO PUERTA DEL LABERINTO ===")
	if _puerta:
		_puerta.abrir()
	DialogoSistema.mostrar_texto(
		"Todas las terminales resueltas.\n"
		+ "La salida ha sido desbloqueada.\n"
		+ "Has demostrado que entiendes los fundamentos de la POO."
	)
