extends CharacterBody2D

# --- REFERENCIAS ---
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_sound = get_node_or_null("jump_sound")
@onready var sonido_muerte: AudioStreamPlayer2D = $Sonido_muerte

# --- CONSTANTES ---
const SPEED = 300.0
const JUMP_VELOCITY = -800.0 # Valor negativo para ir hacia arriba
# --- VARIABLES DE ESTADO ---
var alive = true

func _physics_process(delta: float) -> void:
	if!alive:
		return
		
	# 1. APLICAR GRAVEDAD
	if not is_on_floor():
		velocity += get_gravity() * delta
		# Animación de salto mientras está en el aire
		if animated_sprite_2d.sprite_frames.has_animation("jumping"):
			animated_sprite_2d.play("jumping")
	
	# 2. LÓGICA DE SALTO (Flecha hacia arriba)
	# 'ui_up' es la flecha arriba por defecto en Godot
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if jump_sound:
			jump_sound.play()

	# 3. MOVIMIENTO LATERAL (Flechas izquierda y derecha)
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if direction:
		velocity.x = direction * SPEED
		# Giro del personaje (Flip)
		animated_sprite_2d.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. ANIMACIONES EN EL SUELO
	if is_on_floor():
		if velocity.x != 0:
			if animated_sprite_2d.sprite_frames.has_animation("running"):
				animated_sprite_2d.play("running")
		else:
			if animated_sprite_2d.sprite_frames.has_animation("idle"):
				animated_sprite_2d.play("idle")

	# 5. EJECUTAR EL MOVIMIENTO
	move_and_slide()

# --- FUNCIÓN DE MUERTE ---
func die() -> void:
	if alive:
		sonido_muerte.play()
		animated_sprite_2d.play("dying")
		alive = false
	
	
