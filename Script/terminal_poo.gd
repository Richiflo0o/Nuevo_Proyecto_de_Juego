# terminal_poo.gd
extends StaticBody2D

signal resuelto

var terminal_ui = null

var _resuelta := false

func _ready() -> void:
	await get_tree().process_frame  # espera un frame para que los hijos estén listos
	terminal_ui = get_node_or_null("TerminalUI")
	print("terminal_ui encontrado: ", terminal_ui)
	if terminal_ui:
		terminal_ui.respuesta_correcta.connect(_on_resuelto)
	else:
		push_error("ERROR: No se encontró TerminalUI en " + name)

func interactuar() -> void:
	print("=== INTERACTUAR LLAMADO ===")  # ← agrega
	if _resuelta or not terminal_ui:
		print("Terminal resuelta o sin UI")  # ← agrega
		return
	terminal_ui.abrir()

func _on_resuelto() -> void:
	print("=== TERMINAL_POO: _on_resuelto llamado ===")
	_resuelta = true
	GameManager.registrar_terminal(name)
	terminal_ui.respuesta_correcta.disconnect(_on_resuelto)
	print("Emitiendo señal resuelto...")
	resuelto.emit()
	print("Señal emitida OK")
