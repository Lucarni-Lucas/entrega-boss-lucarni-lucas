extends "res://scenes/enemigos/volador.gd"

@export var escena_hijo: PackedScene
@export var hijos := 2
@export_range(0, 300, 1, "suffix:px") var separacion_hijos := 30.0
@export_range(0, 2000, 10, "suffix:px/s") var empuje_hijos := 500.0

var _spawner: Spawner


func _ready() -> void:
	super()
	_spawner = get_tree().get_first_node_in_group(Spawner.GRUPO) as Spawner
	if _spawner and escena_hijo:
		_spawner.preparar_pool(escena_hijo, hijos * 2)


func _terminar_muerte() -> void:
	if _spawner and escena_hijo:
		_partir(global_position)
	super()


func _partir(desde: Vector2) -> void:
	var giro := randf() * TAU
	for i in hijos:
		var lado := Vector2.from_angle(giro + TAU * i / hijos)
		var hijo := _spawner.aparecer(escena_hijo, desde + Vector2(lado.x, lado.y * 0.65) * separacion_hijos)
		hijo.empujar(desde, empuje_hijos)
