extends Area2D

# Señal para avisar a otros nodos
signal player_died(body)

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 100.0
var direction = -1.0

func _process(delta: float) -> void:
	# Movimiento constante
	position.x += direction * SPEED * delta
	
	# Giro visual simplificado
	animated_sprite_2d.flip_h = (direction > 0)

func _on_timer_timeout() -> void:
	# Cambia dirección
	direction *= -1.0 

func _on_body_entered(body: Node2D) -> void:
	# Usamos has_method para que funcione aunque el nodo no se llame exactamente "Player"
	if body.has_method("die"):
		print("¡El caracol tocó al jugador!")
		
		# MANDATORIO: Llamamos a la función die() del jugador para que ponga alive = false
		# y ejecute la animación de muerte que programamos en el otro script.
		body.die() 
		
		# Emitimos la señal por si quieres usarla en otro lado (ej. para la interfaz)
		emit_signal("player_died", body)
		
		# Opcional: Reiniciar la escena después de un pequeño retraso
		restart_scene()

func restart_scene() -> void:
	# Esperamos 1.5 segundos para que se vea la animación de muerte
	await get_tree().create_timer(1.5).timeout
	get_tree().reload_current_scene()
