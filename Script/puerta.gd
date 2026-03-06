# puerta.gd
# Nodo: StaticBody2D (o AnimatableBody2D si quieres animarla)
#
# Árbol de nodos sugerido:
# Puerta (StaticBody2D)
# ├── Sprite2D
# └── CollisionShape2D

extends StaticBody2D

var _abierta := false

func abrir() -> void:
	if _abierta:
		return
	_abierta = true
	# Opción A: desaparecer (simple)
	visible = false
	$CollisionShape2D.set_deferred("disabled", true)

	# Opción B (si tienes AnimatedSprite2D): reproducir animación
	# $AnimatedSprite2D.play("abrir")
	# await $AnimatedSprite2D.animation_finished
	# $CollisionShape2D.set_deferred("disabled", true)
