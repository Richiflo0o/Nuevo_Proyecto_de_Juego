# terminal_poo.gd
extends StaticBody2D

signal resuelto

@onready var terminal_ui = $TerminalUI

var _resuelta := false

func _ready() -> void:
	if terminal_ui:
		terminal_ui.respuesta_correcta.connect(_on_resuelto)

func interactuar() -> void:
	if _resuelta or not terminal_ui:
		return
	terminal_ui.abrir()

func _on_resuelto() -> void:
	_resuelta = true
	terminal_ui.respuesta_correcta.disconnect(_on_resuelto)
	resuelto.emit()
