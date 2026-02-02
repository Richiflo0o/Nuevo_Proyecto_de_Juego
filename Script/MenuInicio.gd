extends Control

func _ready():
	# Conectamos los botones a sus funciones
	$VBoxContainer/BotonJugar.pressed.connect(_on_jugar_pressed)
	$VBoxContainer/BotonSalir.pressed.connect(_on_salir_pressed)

func _on_jugar_pressed():
	get_tree().change_scene_to_file("res://Scenes/Mundo.tscn")
	
func _on_salir_pressed():
	get_tree().quit() # Cierra el juego
