# game_manager.gd
# Autoload — nombre: GameManager
# Centraliza TODO el estado global y navegación entre escenas.
# Ningún otro script debe llamar get_tree().change_scene_to_file() directamente.

extends Node

# ── Señales ───────────────────────────────────────────────────────────────────
signal vida_cambiada(nueva_vida: int)
signal puntuacion_cambiada(nueva_puntuacion: int)
signal sala_cambiada(numero_sala: int)
signal jugador_muerto
signal juego_completado

# ── Constantes ────────────────────────────────────────────────────────────────
const VIDA_MAXIMA         := 100
const PUNTOS_POR_TERMINAL := 150
const PUNTOS_POR_ENEMIGO  := 50

# Orden de escenas del juego
# IMPORTANTE: nueva_partida() inicia en sala 0 (intro)
#             La intro llama iniciar_juego() al terminar
const SALAS := [
	"res://Scenes/intro_screen.tscn",       # 0 — intro con diapositivas
	"res://Scenes/Salas/Mundo.tscn",        # 1 — mundo tutorial
	"res://Scenes/Salas/laberinto.tscn",    # 2 — laberinto con terminales C#
	"res://Scenes/Salas/Sala3.tscn",        # 3 — sala final (pendiente)
]

const ESCENA_MENU := "res://Scenes/MenuInicio.tscn"

# ── Estado persistente entre salas ────────────────────────────────────────────
var vida                 : int           = VIDA_MAXIMA
var puntuacion           : int           = 0
var sala_actual          : int           = 0
var terminales_resueltas : Array[String] = []

# ── Navegación ────────────────────────────────────────────────────────────────

# Llamado por el botón JUGAR del menú → va a la intro primero
func nueva_partida() -> void:
	vida                 = VIDA_MAXIMA
	puntuacion           = 0
	sala_actual          = 0   # ← empieza en intro_screen.tscn
	terminales_resueltas = []
	_cargar_sala_actual()

# Llamado por intro_screen.gd al terminar las diapositivas → inicia el juego real
func iniciar_juego() -> void:
	sala_actual = 1   # ← Mundo.tscn (tutorial)
	sala_cambiada.emit(sala_actual)
	_cargar_sala_actual()

func ir_a_menu() -> void:
	get_tree().change_scene_to_file(ESCENA_MENU)

func avanzar_sala() -> void:
	sala_actual += 1
	if sala_actual >= SALAS.size():
		juego_completado.emit()
		ir_a_menu()
		return
	sala_cambiada.emit(sala_actual)
	_cargar_sala_actual()

func ir_a_sala(indice: int) -> void:
	if indice < 0 or indice >= SALAS.size():
		push_error("GameManager: índice de sala inválido: %d" % indice)
		return
	sala_actual = indice
	sala_cambiada.emit(sala_actual)
	_cargar_sala_actual()

# ── Vida ──────────────────────────────────────────────────────────────────────

func recibir_danio(cantidad: int) -> void:
	vida = clamp(vida - cantidad, 0, VIDA_MAXIMA)
	vida_cambiada.emit(vida)
	if vida == 0:
		jugador_muerto.emit()
		await get_tree().create_timer(1.0).timeout
		_reiniciar_sala()

func curar(cantidad: int) -> void:
	vida = clamp(vida + cantidad, 0, VIDA_MAXIMA)
	vida_cambiada.emit(vida)

# ── Puntuación y terminales ───────────────────────────────────────────────────

func registrar_terminal(id_terminal: String) -> void:
	if id_terminal in terminales_resueltas:
		return
	terminales_resueltas.append(id_terminal)
	agregar_puntos(PUNTOS_POR_TERMINAL)

func registrar_enemigo_eliminado() -> void:
	agregar_puntos(PUNTOS_POR_ENEMIGO)

func agregar_puntos(cantidad: int) -> void:
	puntuacion += cantidad
	puntuacion_cambiada.emit(puntuacion)

func terminal_resuelta(id_terminal: String) -> bool:
	return id_terminal in terminales_resueltas

# ── Privados ──────────────────────────────────────────────────────────────────

func _cargar_sala_actual() -> void:
	var ruta : String = SALAS[sala_actual]
	get_tree().change_scene_to_file(ruta)

func _reiniciar_sala() -> void:
	vida = VIDA_MAXIMA
	vida_cambiada.emit(vida)
	_cargar_sala_actual()
