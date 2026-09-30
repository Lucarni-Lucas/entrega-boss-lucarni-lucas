extends Node

@export var jugador: Player
@export var origen: Hitbox.Origen = Hitbox.Origen.GROUND_POUND

var _muertes := 0


func _on_spawner_enemigo_murio(_posicion: Vector2, origen_muerte: Hitbox.Origen) -> void:
	if origen_muerte != origen:
		return
	_muertes += 1
	if _muertes >= jugador.params.curacion_cada_muertes:
		_muertes = 0
		jugador.curar(jugador.params.curacion_cantidad)
