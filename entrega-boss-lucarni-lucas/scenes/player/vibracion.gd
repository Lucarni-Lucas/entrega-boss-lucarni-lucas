extends Node


func vibrar() -> void:
	if EsquemaInput.actual != EsquemaInput.Esquema.JOYSTICK:
		return
	var params: PlayerParams = get_parent().params
	for dispositivo in Input.get_connected_joypads():
		Input.start_joy_vibration(dispositivo, params.vibracion_golpe, 0.0, params.vibracion_duracion)
