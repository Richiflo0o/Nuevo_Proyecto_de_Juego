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
	actualizar_direccion_rayo(direction)
	actualizar_animacion(direction)
	
	# Multiplicamos por 25 o 30 para darle alcance frente al personaje
	if direction.length() > 0:
		ray.target_position = direction * 25	

func actualizar_direccion_rayo(dir: Vector2):
	# Si el jugador se está moviendo, el rayo apunta en esa dirección
	if dir.length() > 0:
		ray.target_position = dir.normalized() * 30
	# Si está quieto, el rayo ya se queda apuntando a la última dirección
	# porque no lo reseteamos a (0,0).
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
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		GameManager.ir_a_menu()
	if event.is_action_pressed("interactuar"): # Define "E" en el Input Map
		print("=== TECLA E PRESIONADA ===")
		if ray.is_colliding():
			print("Ray colisionando con: ", ray.get_collider())
			var objeto = ray.get_collider()
			if objeto.has_method("interactuar"):
				objeto.interactuar()
		else:
			print("Ray NO está colisionando")
