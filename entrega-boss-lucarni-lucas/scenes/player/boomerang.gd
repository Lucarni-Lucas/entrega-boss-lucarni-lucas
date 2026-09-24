extends VerboExclusivo

signal lanzo


const _INTERRUMPIBLES := [Player.Estado.GROUND_POUND, Player.Estado.DIVE]

@export var escena_boomerang: PackedScene

var _tiempo_recuperacion := 0.0
var _proyectil: Boomerang


func estado() -> Player.Estado:
	return Player.Estado.THROW


func procesar_fisica(player: Player, delta: float) -> void:
	if _proyectil == null:
		_crear_proyectil(player)
	_actualizar_disponibilidad(player)
	if player.verbo_activo == self:
		_tiempo_recuperacion -= delta
		if _tiempo_recuperacion <= 0.0:
			player.escala_gravedad = 1.0
			player.liberar_verbo(self)
	elif Input.is_action_just_pressed("boomerang"):
		player.intentar_activar(self)


func estados_validos() -> Array:
	return [Player.Estado.EN_SUELO, Player.Estado.EN_AIRE, Player.Estado.GROUND_POUND, Player.Estado.DIVE]


func esta_disponible(player: Player) -> bool:
	return player.tiene_boomerang


func puede_interrumpir(otro: VerboExclusivo) -> bool:
	return otro.estado() in _INTERRUMPIBLES


func activar(player: Player) -> void:
	_proyectil.lanzar(player, player.ultima_direccion)
	player.tiene_boomerang = false
	_tiempo_recuperacion = player.params.throw_duracion
	player.escala_gravedad = player.params.throw_escala_gravedad
	player.velocidad_z = 0.0
	lanzo.emit()


func cancelar(player: Player) -> void:
	player.escala_gravedad = 1.0


func _actualizar_disponibilidad(player: Player) -> void:
	if _proyectil.en_vuelo:
		return
	if player.esta_en_suelo():
		player.tiene_boomerang = true


func _crear_proyectil(player: Player) -> void:
	_proyectil = escena_boomerang.instantiate()
	player.agregar_al_mundo(_proyectil)
	_proyectil.precalentar()
