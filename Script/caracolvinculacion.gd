extends Area2D

# Definimos la señal
signal player_died(body)

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 100.0
var direction = -1.0

func _process(delta: float) -> void:
	# Movimiento del caracol
	position.x += direction * SPEED * delta
	
	# Control de hacia dónde mira el sprite
	animated_sprite_2d.flip_h = (direction > 0)

func _on_timer_timeout() -> void:
	# Cambia de dirección
	direction *= -1.0 

func _on_body_entered(body: Node2D) -> void:
	# 1. Verificamos si el cuerpo tiene la función "die" (tu personaje la tiene)
	if body.has_method("die"):
		print("¡Colisión con el jugador!")
		body.die() # Esto activa la animación "dying" y pone alive = false
		emit_signal("player_died", body)
	
	
	
