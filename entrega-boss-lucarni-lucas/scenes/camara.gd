extends Camera2D

@export var params: CameraParams
@export var objetivo: Node2D


func _ready() -> void:
	if objetivo == null:
		return
	zoom = Vector2.ONE * _zoom_necesario(_seguir())
	reset_smoothing()


func _physics_process(delta: float) -> void:
	if objetivo == null:
		return
	_acomodar_zoom(_seguir(), delta)


func _extremos() -> Vector2:
	if objetivo.has_method("extremos_verticales"):
		return objetivo.extremos_verticales()
	var y := objetivo.global_position.y
	return Vector2(y, y)


func _seguir() -> Vector2:
	var extremos := _extremos()
	global_position = Vector2(objetivo.global_position.x, _centro_y(extremos))
	return extremos


func _centro_y(extremos: Vector2) -> float:
	var exceso := maxf(extremos.y - extremos.x - params.banda_muerta, 0.0)
	return extremos.y - exceso * params.seguimiento_vertical


func _zoom_necesario(extremos: Vector2) -> float:
	var centro := _centro_y(extremos)
	var mitad_necesaria := maxf(centro - extremos.x, extremos.y - centro) + params.margen_vertical
	var mitad_disponible := get_viewport_rect().size.y / 2.0
	return clampf(mitad_disponible / maxf(mitad_necesaria, 1.0), params.zoom_min, 1.0)


func _acomodar_zoom(extremos: Vector2, delta: float) -> void:
	var destino := Vector2.ONE * _zoom_necesario(extremos)
	zoom = zoom.lerp(destino, 1.0 - exp(-params.velocidad_zoom * delta))
