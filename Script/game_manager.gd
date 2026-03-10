# game_manager.gd
# Autoload — nombre: GameManager
# Trackea el estado global del juego entre salas.

extends Node

# ── Señales ───────────────────────────────────────────────────────────────────
signal vida_cambiada(nueva_vida: int)
signal puntuacion_cambiada(nueva_puntuacion: int)
signal sala_cambiada(numero_sala: int)
signal jugador_muerto
signal juego_completado

# ── Constantes ────────────────────────────────────────────────────────────────
const VIDA_MAXIMA       := 100
const PUNTOS_POR_TERMINAL := 150
const PUNTOS_POR_ENEMIGO  := 50

# Rutas de las salas en orden secuencial
# Agrégalas aquí conforme las vayas creando

const SALAS = [
"res://Scenes/Salas/Mundo.tscn",
"res://Scenes/Salas/laberinto.tscn"
]

# ── Estado persistente entre salas ────────────────────────────────────────────
var vida            : int  = VIDA_MAXIMA
var puntuacion      : int  = 0
var sala_actual     : int  = 0   # índice en SALAS
var terminales_resueltas : Array[String] = []  # IDs de terminales ya resueltas

# ── API pública ───────────────────────────────────────────────────────────────

# Llamar al iniciar una partida nueva desde el menú
func nueva_partida() -> void:
	vida                 = VIDA_MAXIMA
	puntuacion           = 0
	sala_actual          = 0
	terminales_resueltas = []
	_cargar_sala_actual()

# Llamar cuando el jugador llega a la puerta de salida
func avanzar_sala() -> void:
	sala_actual += 1
	if sala_actual >= SALAS.size():
		juego_completado.emit()
		get_tree().change_scene_to_file("res://Scenes/MenuInicio.tscn")
		return
	sala_cambiada.emit(sala_actual)
	_cargar_sala_actual()

# Llamar cuando el jugador recibe daño
func recibir_danio(cantidad: int) -> void:
	vida = clamp(vida - cantidad, 0, VIDA_MAXIMA)
	vida_cambiada.emit(vida)
	if vida == 0:
		jugador_muerto.emit()
		await get_tree().create_timer(1.0).timeout
		_reiniciar_sala()

# Llamar cuando el jugador se cura
func curar(cantidad: int) -> void:
	vida = clamp(vida + cantidad, 0, VIDA_MAXIMA)
	vida_cambiada.emit(vida)

# Llamar cuando el jugador resuelve una terminal
func registrar_terminal(id_terminal: String) -> void:
	if id_terminal in terminales_resueltas:
		return
	terminales_resueltas.append(id_terminal)
	agregar_puntos(PUNTOS_POR_TERMINAL)

# Llamar cuando el jugador elimina un enemigo
func registrar_enemigo_eliminado() -> void:
	agregar_puntos(PUNTOS_POR_ENEMIGO)

func agregar_puntos(cantidad: int) -> void:
	puntuacion += cantidad
	puntuacion_cambiada.emit(puntuacion)

# Consultar si una terminal ya fue resuelta (útil al recargar la sala)
func terminal_resuelta(id_terminal: String) -> bool:
	return id_terminal in terminales_resueltas

# ── Privados ──────────────────────────────────────────────────────────────────
func _cargar_sala_actual() -> void:

	get_tree().change_scene_to_file(SALAS[sala_actual])

func _reiniciar_sala() -> void:
	# Conserva puntuación y terminales resueltas, solo reinicia la vida
	vida = VIDA_MAXIMA
	vida_cambiada.emit(vida)
	_cargar_sala_actual()
