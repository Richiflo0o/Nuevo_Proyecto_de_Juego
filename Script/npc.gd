# npc.gd
# Nodo: StaticBody2D
# NPC que explica los controles al jugador.
# Se activa con la tecla E igual que la terminal.
#
# Árbol de nodos:
# NPC (StaticBody2D)
# ├── Sprite2D
# ├── CollisionShape2D
# └── Indicador (Label)  ← "[E]" flotante, visible al acercarse

extends StaticBody2D

# Secuencia de mensajes del NPC — se muestran uno por uno
const MENSAJES := [
	"Hola. Soy un fragmento de memoria del sistema.",
	"Te explicaré cómo moverte en este entorno:\n\n[W A S D] o [↑ ↓ ← →] para moverte.",
	"Presiona [E] para interactuar con objetos\ncomo terminales o NPCs como yo.",
	"Presiona [ESC] para volver al menú principal.",
	"Hay bugs merodeando por aquí.\nAcércate a ellos para eliminarlos.",
	"Y una cosa más...\nel sistema está observando cada movimiento que haces.",
]

@onready var indicador = $Indicador

var _hablado := false

func _ready() -> void:
	if indicador:
		indicador.visible = false

func interactuar() -> void:
	if _hablado:
		# Mensaje corto si ya habló antes
		DialogoSistema.mostrar_texto("Ya te dije todo lo que sé.\nAhora depende de ti.")
		return
	_hablado = true
	# Mostrar todos los mensajes en secuencia
	for mensaje in MENSAJES:
		DialogoSistema.mostrar_texto(mensaje)
		# Esperar a que el diálogo termine antes del siguiente
		await DialogoSistema.terminal_cerrada

# Mostrar/ocultar indicador [E] al acercarse
func mostrar_indicador(visible: bool) -> void:
	if indicador:
		indicador.visible = visible
