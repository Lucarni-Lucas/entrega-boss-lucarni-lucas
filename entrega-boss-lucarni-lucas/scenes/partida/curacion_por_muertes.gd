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
		jugador.curar(jugador.params.curacion_cantidad)
	progreso_cambio.emit(_curaciones + float(_muertes) / necesarias)
