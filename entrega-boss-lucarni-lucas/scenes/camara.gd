extends Camera2D

@export var params: CameraParams
@export var objetivo: Node2D

var _zoom_base := Vector2.ONE
var _golpe := 1.0
var _tween_golpe: Tween


func _ready() -> void:
	if objetivo == null:
		return
	saltar_al_objetivo()


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
	_zoom_base = _zoom_base.lerp(destino, 1.0 - exp(-params.velocidad_zoom * delta))
	zoom = _zoom_base * _golpe


func _process(_delta: float) -> void:
	zoom = _zoom_base * _golpe


func saltar_al_objetivo() -> void:
	_zoom_base = Vector2.ONE * _zoom_necesario(_seguir())
	zoom = _zoom_base * _golpe
	reset_smoothing()
	force_update_scroll()


func golpe_de_zoom(factor: float, duracion: float) -> void:
	if _tween_golpe:
		_tween_golpe.kill()
	_tween_golpe = create_tween().set_ignore_time_scale(true)
	_tween_golpe.tween_property(self, "_golpe", factor, duracion * 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween_golpe.tween_property(self, "_golpe", 1.0, duracion * 0.75).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
