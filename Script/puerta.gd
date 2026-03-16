# puerta.gd
# Nodo: StaticBody2D
#
# Árbol de nodos:
# Puerta (StaticBody2D)
# ├── Sprite2D
# ├── CollisionShape2D
# └── IndicadorLabel (Label) ← "[E] Entrar" — visible solo cuando está abierta

extends StaticBody2D

const ESCENA_DESTINO := "res://Scenes/Salas/laberinto.tscn"

var _abierta := false

var indicador = null

func _ready() -> void:
	# La puerta empieza cerrada e invisible
	visible = false
	if indicador:
		indicador.visible = false
	$CollisionShape2D.set_deferred("disabled", true)

# Llamado desde mundo_inicial.gd cuando se completan los objetivos
func abrir() -> void:
	print("=== PUERTA.ABRIR() ===")
	if _abierta:
		print("Ya estaba abierta")
		return
	_abierta = true
	visible = true
	print("Puerta visible: ", visible)
	modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.8)
	await tween.finished

	# Habilitar colisión e indicador
	$CollisionShape2D.set_deferred("disabled", false)
	if indicador:
		indicador.visible = true

# Llamado desde player.gd al presionar E cerca de la puerta
func interactuar() -> void:
	if not _abierta:
		return
	GameManager.avanzar_sala()
