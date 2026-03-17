extends CharacterBody2D

@export var speed := 100.0
@onready var sprite = $Sprite2D
@onready var ray    = $RayCast2D

var ultima_direccion := "down"

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction.normalized() * speed
	move_and_slide()
	_actualizar_direccion_rayo(direction)
	_actualizar_animacion(direction)
	if direction.length() > 0:
		ray.target_position = direction * 25

func _actualizar_direccion_rayo(dir: Vector2):
	if dir.length() > 0:
		ray.target_position = dir.normalized() * 30

func _actualizar_animacion(dir: Vector2):
	if dir.length() > 0.1:
		if abs(dir.x) > abs(dir.y):
			ultima_direccion = "right" if dir.x > 0 else "left"
		else:
			ultima_direccion = "down" if dir.y > 0 else "up"
		sprite.play("run_" + ultima_direccion)
	else:
		sprite.play("Idle_" + ultima_direccion)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		GameManager.ir_a_menu()
	if event.is_action_pressed("interactuar"):
		print("=== TECLA E PRESIONADA ===")
		if ray.is_colliding():
			var objeto = ray.get_collider()
			if objeto.has_method("interactuar"):
				objeto.interactuar()
