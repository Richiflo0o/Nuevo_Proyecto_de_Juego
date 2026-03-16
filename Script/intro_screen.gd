# intro_screen.gd
# Nodo raíz: Control
#
# Árbol de nodos:
# IntroScreen (Control)
# ├── Fondo (ColorRect)
# ├── Imagen (TextureRect)
# └── ContinuarLabel (Label)

extends Control

# ── Diapositivas ─────────────────────────────────────────
# Las imágenes deben estar en:
# res://Assets/intro/

const DIAPOSITIVAS := [
	"res://Assets/intro/intro_01.png",
	"res://Assets/intro/intro_02.png",
	"res://Assets/intro/intro_03.png",
	"res://Assets/intro/intro_04.png",
	"res://Assets/intro/intro_05.png",
	"res://Assets/intro/intro_06.png",
	"res://Assets/intro/intro_07.png",
	"res://Assets/intro/intro_08.png"
]

const TIEMPO_AUTO := 6.0
const TIEMPO_FADE := 0.5

# ── Variables ─────────────────────────────────────────────
var _tween_parpadeo : Tween = null

# ── Nodos ─────────────────────────────────────────────────
@onready var _imagen : TextureRect = $Imagen
@onready var _continuar_label : Label = $ContinuarLabel

# ── Estado ────────────────────────────────────────────────
var _indice_actual := 0
var _puede_avanzar := false
var _timer_auto : SceneTreeTimer = null

# ── Inicio ────────────────────────────────────────────────
func _ready() -> void:
	_continuar_label.visible = false
	_imagen.modulate.a = 0.0
	_mostrar_diapositiva(0)

func _input(event: InputEvent) -> void:
	if not _puede_avanzar:
		return

	if event.is_pressed() and not event.is_echo():
		_avanzar()

# ── Mostrar diapositiva ───────────────────────────────────
func _mostrar_diapositiva(idx: int) -> void:

	_puede_avanzar = false
	_continuar_label.visible = false

	if idx > 0:
		var tween_out := create_tween()
		tween_out.tween_property(_imagen, "modulate:a", 0.0, TIEMPO_FADE)
		await tween_out.finished

	var textura = load(DIAPOSITIVAS[idx])

	if textura:
		_imagen.texture = textura
	else:
		push_warning("No se encontró: " + DIAPOSITIVAS[idx])

	var tween_in := create_tween()
	tween_in.tween_property(_imagen, "modulate:a", 1.0, TIEMPO_FADE)
	await tween_in.finished

	_puede_avanzar = true
	_continuar_label.visible = true
	_parpadear_continuar()

	_timer_auto = get_tree().create_timer(TIEMPO_AUTO)
	_timer_auto.timeout.connect(_on_timer_auto)

func _on_timer_auto() -> void:
	_avanzar()

# ── Avanzar ───────────────────────────────────────────────
func _avanzar() -> void:

	if not _puede_avanzar:
		return

	_puede_avanzar = false

	if _tween_parpadeo:
		_tween_parpadeo.kill()
		_tween_parpadeo = null

	_indice_actual += 1

	if _indice_actual >= DIAPOSITIVAS.size():
		_terminar()
	else:
		_mostrar_diapositiva(_indice_actual)

# ── Terminar intro ────────────────────────────────────────
func _terminar() -> void:

	var tween := create_tween()
	tween.tween_property(_imagen, "modulate:a", 0.0, TIEMPO_FADE)

	await tween.finished

	GameManager.nueva_partida()

# ── Parpadeo del texto ────────────────────────────────────
func _parpadear_continuar() -> void:

	var tween := create_tween().set_loops()

	tween.tween_property(_continuar_label, "modulate:a", 0.3, 0.4)
	tween.tween_property(_continuar_label, "modulate:a", 1.0, 0.6)

	_tween_parpadeo = tween
