extends Node2D
class_name Diamante

@export_range(0, 100, 1, "suffix:px") var elevacion := 32.0

@onready var _sombra: Sombra = $Sombra
@onready var _visual: Sprite2D = $Visual


func ubicar(posicion: Vector2, z: float, delante: bool) -> void:
	global_position = posicion
	_sombra.actualizar(z)
	_visual.position = Vector2(0, -z - elevacion)
	_visual.z_index = 1 if delante else -1
