extends Node

signal progreso_cambio(progreso: float)

@export var jugador: Player
@export var origen: Hitbox.Origen = Hitbox.Origen.GROUND_POUND

var _muertes := 0
var _curaciones := 0


func _on_spawner_enemigo_murio(_posicion: Vector2, origen_muerte: Hitbox.Origen) -> void:
	if origen_muerte != origen:
		return
	_muertes += 1
	var necesarias := jugador.params.curacion_cada_muertes
	if _muertes >= necesarias:
		_muertes = 0
		_curaciones += 1
		var cantidad := jugador.params.curacion_cantidad
		if jugador.vida < jugador.params.vida_max * jugador.params.curacion_umbral_vida_baja:
			cantidad *= jugador.params.curacion_multiplicador_vida_baja
		jugador.curar(cantidad)
	progreso_cambio.emit(_curaciones + float(_muertes) / necesarias)
