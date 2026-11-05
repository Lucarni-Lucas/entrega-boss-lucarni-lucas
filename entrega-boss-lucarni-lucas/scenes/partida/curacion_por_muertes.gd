extends Node

@export var jugador: Player

var _muertes := 0


func _on_spawner_enemigo_murio(_posicion: Vector2, _origen: Hitbox.Origen) -> void:
	_muertes += 1
	if _muertes < jugador.params.curacion_cada_muertes:
		return
	_muertes = 0
	var cantidad := jugador.params.curacion_cantidad
	if jugador.vida < jugador.params.vida_max * jugador.params.curacion_umbral_vida_baja:
		cantidad *= jugador.params.curacion_multiplicador_vida_baja
	jugador.curar(cantidad)


func reiniciar() -> void:
	_muertes = 0
