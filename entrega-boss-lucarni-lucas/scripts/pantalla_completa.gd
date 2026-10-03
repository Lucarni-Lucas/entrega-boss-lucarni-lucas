extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pantalla_completa"):
		return
	var completa := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if completa else DisplayServer.WINDOW_MODE_FULLSCREEN)
	get_viewport().set_input_as_handled()
