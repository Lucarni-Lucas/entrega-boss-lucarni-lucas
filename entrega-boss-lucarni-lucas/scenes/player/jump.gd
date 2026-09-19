extends Node

signal salto

var _tiempo_buffer := 0.0

func procesar_fisica(player: Player, delta: float) -> void:
	_tiempo_buffer = maxf(_tiempo_buffer - delta, 0.0)
	if Input.is_action_just_pressed("saltar"):
		_tiempo_buffer = player.params.salto_buffer

	if _tiempo_buffer > 0.0 and player.esta_en_suelo():
		_tiempo_buffer = 0.0
		player.aplicar_impulso_vertical(player.params.fuerza_salto)
		salto.emit()
