extends Node

signal salto

var _tiempo_buffer := 0.0


func procesar_fisica(player: Player, delta: float) -> void:
	_tiempo_buffer = maxf(_tiempo_buffer - delta, 0.0)
	## Por encima de esa altura la tecla compartida es ground pound, no salto.
	if Input.is_action_just_pressed("saltar") and player.z < player.params.gp_altura_minima:
		_tiempo_buffer = player.params.salto_buffer

	if _tiempo_buffer > 0.0 and player.estado_actual() == Player.Estado.EN_SUELO:
		_tiempo_buffer = 0.0
		player.aplicar_impulso_vertical(player.params.fuerza_salto)
		salto.emit()
