extends StaticBody2D
@onready var terminal_codigo = $TerminalCodigo

func _ready() -> void:
	terminal_codigo.respuesta_correcta.connect(
		func(): GameManager.registrar_terminal(name)
	)
