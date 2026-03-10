# intro_screen.gd
# Nodo raíz: Control
#
# Árbol de nodos:
# IntroScreen (Control)  ← Full Rect
# ├── Fondo (ColorRect)          ← negro, Full Rect
# ├── Imagen (TextureRect)       ← Full Rect, Expand: Fit Width Proportional
# └── ContinuarLabel (Label)     ← "[ Presiona cualquier tecla ]" — abajo centrado

extends Control

# ── Diapositivas en orden narrativo ──────────────────────────────────────────
# Pon estas imágenes en res://Assets/Intro/
# intro_01.jpg → Portada "El Último Compilador"
# intro_02.jpg → Estudiantes crean el sistema
# intro_03.jpg → El sistema en entorno virtual
# intro_04.jpg → El sistema modifica su código
# intro_05.jpg → El programa sigue ejecutándose
# intro_06.jpg → El jugador entra al entorno
const DIAPOSITIVAS := [
	"res://Assets/Intro/intro_01.jpg",
	"res://Assets/Intro/intro_02.jpg",
	"res://Assets/Intro/intro_03.jpg",
	"res://Assets/Intro/intro_04.jpg",
	"res://Assets/Intro/intro_05.jpg",
	"res://Assets/Intro/intro_06.jpg",
	"res://Assets/Intro/intro_07.jpg",
]

const TIEMPO_AUTO := 6.0   # segundos por diapositiva antes de avanzar sola
const TIEMPO_FADE := 0.5   # duración del fade entre diapositivas
# ── Varriables ────────────────────────────────────────────────────────────────
var _tween_parpadeo : Tween = null
# ── Nodos ─────────────────────────────────────────────────────────────────────
@onready var _imagen          : TextureRect = $Imagen
@onready var _continuar_label : Label       = $ContinuarLabel

# ── Estado ────────────────────────────────────────────────────────────────────
var _indice_actual := 0
var _puede_avanzar := false
var _timer_auto    : SceneTreeTimer = null

# ── Ciclo de vida ─────────────────────────────────────────────────────────────
func _ready() -> void:
	_continuar_label.visible = false
	_imagen.modulate.a = 0.0
	_mostrar_diapositiva(0)

func _input(event: InputEvent) -> void:
	if not _puede_avanzar:
		return
	if event.is_pressed() and not event.is_echo():
		_avanzar()

# ── Lógica de diapositivas ────────────────────────────────────────────────────
func _mostrar_diapositiva(idx: int) -> void:
	_puede_avanzar = false
	_continuar_label.visible = false

	# Fade out (solo si no es la primera)
	if idx > 0:
		var tween_out := create_tween()
		tween_out.tween_property(_imagen, "modulate:a", 0.0, TIEMPO_FADE)
		await tween_out.finished

	# Cargar imagen
	var textura = load(DIAPOSITIVAS[idx])
	if textura:
		_imagen.texture = textura
	else:
		push_warning("IntroScreen: no se encontró: " + DIAPOSITIVAS[idx])

	# Fade in
	var tween_in := create_tween()
	tween_in.tween_property(_imagen, "modulate:a", 1.0, TIEMPO_FADE)
	await tween_in.finished

	# Habilitar avance y mostrar hint
	_puede_avanzar = true
	_continuar_label.visible = true
	_parpadear_continuar()

	# Avance automático después de TIEMPO_AUTO segundos
	_timer_auto = get_tree().create_timer(TIEMPO_AUTO)
	_timer_auto.timeout.connect(_on_timer_auto)

func _on_timer_auto() -> void:
	_avanzar()

func _avanzar() -> void:
	if not _puede_avanzar:
		return
	_puede_avanzar = false
	# Detener parpadeo
	if _tween_parpadeo:
		_tween_parpadeo.kill()
		_tween_parpadeo = null
	_indice_actual += 1
	if _indice_actual >= DIAPOSITIVAS.size():
		_terminar()
	else:
		_mostrar_diapositiva(_indice_actual)

func _terminar() -> void:
	# Fade a negro y arrancar el juego
	var tween := create_tween()
	tween.tween_property(_imagen, "modulate:a", 0.0, TIEMPO_FADE)
	await tween.finished
	GameManager.avanzar_sala()

# ── Parpadeo del hint ─────────────────────────────────────────────────────────
func _parpadear_continuar() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(_continuar_label, "modulate:a", 0.3, 0.4)
	tween.tween_property(_continuar_label, "modulate:a", 1.0, 0.6)
	# Guardar referencia para poder pararlo
	_tween_parpadeo = tween
