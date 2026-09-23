extends Node

signal termino(posicion: Vector2)

const estado := Player.Estado.DIVE
const _INTERRUMPIBLES := [Player.Estado.GROUND_POUND, Player.Estado.THROW]

var _direccion := Vector2.ZERO


func procesar_fisica(player: Player, _delta: float) -> void:
	if player.verbo_activo == self:
		_procesar_dive(player)
	elif Input.is_action_just_pressed("dive") and player.intentar_activar(self):
		_procesar_dive(player)


func estados_validos() -> Array:
	return [Player.Estado.EN_AIRE, Player.Estado.GROUND_POUND, Player.Estado.THROW]


func esta_disponible(_player: Player) -> bool:
	return true


func puede_interrumpir(otro: Node) -> bool:
	return otro.estado in _INTERRUMPIBLES


func activar(player: Player) -> void:
	_direccion = player.ultima_direccion
	player.escala_gravedad = player.params.dive_escala_gravedad
	player.aplicar_impulso_vertical(player.params.dive_impulso_vertical)


func cancelar(player: Player) -> void:
	player.escala_gravedad = 1.0


func _procesar_dive(player: Player) -> void:
	player.velocity = _direccion * player.params.dive_velocidad
	if player.esta_en_suelo():
		player.escala_gravedad = 1.0
		player.liberar_verbo(self)
		termino.emit(player.global_position)
