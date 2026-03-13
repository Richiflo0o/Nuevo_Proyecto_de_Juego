# panel_controles.gd
# Nodo: CanvasLayer
# Muestra los controles al inicio y desaparece sola.
#
# Árbol de nodos:
# PanelControles (CanvasLayer)
# └── Panel
#     ├── TituloLabel (Label)   ← "CONTROLES"
#     └── TextoLabel (Label)    ← el texto con los controles

extends CanvasLayer

const TIEMPO_VISIBLE  := 5.0   # segundos antes de empezar a desaparecer
const TIEMPO_FADE_OUT := 1.2   # duración del fade out

@onready var _panel : Panel = $Panel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Posición esquina superior izquierda con margen
	_panel.position = Vector2(16, 16)

	# Mostrar y luego desaparecer automáticamente
	_panel.modulate.a = 0.0
	visible = true
	_fade_in()

func _fade_in() -> void:
	var tween := create_tween()
	tween.tween_property(_panel, "modulate:a", 1.0, 0.4)  # ← _panel
	await tween.finished
	await get_tree().create_timer(TIEMPO_VISIBLE).timeout
	_fade_out()

func _fade_out() -> void:
	var tween := create_tween()
	tween.tween_property(_panel, "modulate:a", 0.0, TIEMPO_FADE_OUT)  # ← _panel
	await tween.finished
	queue_free()
