extends Node

func procesar_fisica(player: Player, _delta: float) -> void:
	var direccion := Input.get_vector("mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo")
	player.velocity = direccion * player.params.velocidad
	if direccion != Vector2.ZERO:
		player.ultima_direccion = direccion
