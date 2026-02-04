extends CharacterBody2D

@export var speed := 100.0
@onready var sprite = $Sprite2D
@onready var ray = $RayCast2D

# Guardamos la última dirección para saber hacia dónde mirar cuando se detiene
var ultima_direccion := "down"

func _physics_process(_delta):
	# 1. Obtener el vector de movimiento (Input Map: arriba, abajo, izq, der)
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# 2. Aplicar velocidad
	velocity = direction.normalized() * speed
	move_and_slide()
	
	# 3. Gestionar Animaciones
	actualizar_animacion(direction)
	

func actualizar_animacion(dir: Vector2):
	# Usamos un pequeño margen (0.1) en lugar de 0 para mayor estabilidad
	if dir.length() > 0.1:
		# lodigca del movimiento
		#abs = valor absoluto
		if abs(dir.x) > abs(dir.y):
			ultima_direccion = "right" if dir.x > 0 else "left"
		else:
			ultima_direccion = "down" if dir.y > 0 else "up"
		
		sprite.play("run_" + ultima_direccion)
	else:
		sprite.play("Idle_" + ultima_direccion)
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):  # La tecla ESC por defecto
		get_tree().change_scene_to_file("res://Scenes/MenuInicio.tscn")
	if event.is_action_pressed("interactuar"): # Define "E" en el Input Map
		if ray.is_colliding():
			var objeto = ray.get_collider()
			if objeto.has_method("interactuar"):
				objeto.interactuar()
