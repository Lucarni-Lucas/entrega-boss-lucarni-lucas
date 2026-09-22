extends Node

const _ESTADOS_VALIDOS := [Player.Estado.EN_SUELO, Player.Estado.EN_AIRE]


func procesar_fisica(player: Player, _delta: float) -> void:
	if not player.estado_actual() in _ESTADOS_VALIDOS:
		return
	var direccion := Input.get_vector("mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo")
	player.velocity = direccion * player.params.velocidad
	if direccion != Vector2.ZERO:
		player.ultima_direccion = direccion
