extends Node

const _ESTADOS_VALIDOS := [Player.Estado.EN_SUELO, Player.Estado.EN_AIRE, Player.Estado.THROW]


func procesar_fisica(player: Player, _delta: float) -> void:
	var estado := player.estado_actual()
	if not estado in _ESTADOS_VALIDOS:
		return
	var direccion := Input.get_vector("mover_izquierda", "mover_derecha", "mover_arriba", "mover_abajo")
	var factor := player.params.throw_factor_velocidad if estado == Player.Estado.THROW else 1.0
	player.velocity = direccion * player.params.velocidad * factor
	if direccion != Vector2.ZERO:
		player.ultima_direccion = direccion
