extends VerboExclusivo

signal termino(posicion: Vector2)
signal empezo
signal toco_enemigo(posicion: Vector2)

const _INTERRUMPIBLES := [Player.Estado.GROUND_POUND, Player.Estado.THROW]

var _direccion := Vector2.ZERO
var _cargas := 0
var _toco_enemigo := false

@onready var _detector: Area2D = $DetectorEnemigos


func estado() -> Player.Estado:
	return Player.Estado.DIVE


func procesar_fisica(player: Player, _delta: float) -> void:
	if player.esta_en_suelo():
		_cargas = player.params.dive_cargas_max
	if player.verbo_activo == self:
		_procesar_dive(player)
	elif Input.is_action_just_pressed("dive") and player.intentar_activar(self):
		_procesar_dive(player)


func estados_validos() -> Array:
	return [Player.Estado.EN_AIRE, Player.Estado.GROUND_POUND, Player.Estado.THROW]


func puede_interrumpir(otro: VerboExclusivo) -> bool:
	return otro.estado() in _INTERRUMPIBLES


func esta_disponible(_player: Player) -> bool:
	return _cargas > 0


func activar(player: Player) -> void:
	_cargas -= 1
	_toco_enemigo = false
	_direccion = player.ultima_direccion
	player.escala_gravedad = player.params.dive_escala_gravedad
	player.aplicar_impulso_vertical(player.params.dive_impulso_vertical)
	player.recargar_energia_gp(player.params.gp_recarga_dive)
	empezo.emit()


func cancelar(player: Player) -> void:
	player.escala_gravedad = 1.0


func _procesar_dive(player: Player) -> void:
	player.velocity = _direccion * player.params.dive_velocidad
	if not _toco_enemigo and _toca_enemigo(player):
		_toco_enemigo = true
		toco_enemigo.emit(player.global_position)
	if player.esta_en_suelo():
		player.escala_gravedad = 1.0
		player.liberar_verbo(self)
		termino.emit(player.global_position)


func _toca_enemigo(player: Player) -> bool:
	for area in _detector.get_overlapping_areas():
		if area is Hurtbox and Altura.rangos_se_tocan(player.z, player.z + player.params.alto_cuerpo, area.z_min, area.z_max):
			return true
	return false
