extends Node

signal lanzo

const estado := Player.Estado.THROW
const _ESCENA := preload("res://scenes/boomerang/boomerang.tscn")
const _INTERRUMPIBLES := [Player.Estado.GROUND_POUND, Player.Estado.DIVE]

var _tiempo_recuperacion := 0.0
var _proyectil: Boomerang


func procesar_fisica(player: Player, delta: float) -> void:
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


func puede_interrumpir(otro: Node) -> bool:
	return otro.estado in _INTERRUMPIBLES


func activar(player: Player) -> void:
	_proyectil = _ESCENA.instantiate()
	player.agregar_al_mundo(_proyectil)
	_proyectil.lanzar(player, player.ultima_direccion)
	player.tiene_boomerang = false
	_tiempo_recuperacion = player.params.throw_duracion
	player.escala_gravedad = player.params.throw_escala_gravedad
	player.velocidad_z = 0.0
	lanzo.emit()


func cancelar(player: Player) -> void:
	player.escala_gravedad = 1.0


func _actualizar_disponibilidad(player: Player) -> void:
	if is_instance_valid(_proyectil):
		return
	_proyectil = null
	if player.esta_en_suelo():
		player.tiene_boomerang = true
