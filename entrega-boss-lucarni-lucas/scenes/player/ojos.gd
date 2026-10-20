extends Node2D

@export_range(0, 90, 1, "suffix:°") var separacion := 19.0
@export var radio := 22.0
@export var altura_suelo := 10.0
@export var altura_aire := 4.0
@export var profundidad := 6.0
@export_range(0, 1, 0.05) var alpha_detras := 0.35
@export_range(0, 1, 0.05) var ancho_minimo := 0.7
@export var velocidad_giro := 12.0
@export var corrimiento_por_velocidad := 0.04
@export var corrimiento_max := 12.0
@export var limite := 24.0

var _angulo := 0.0

@onready var _ojos: Array[Sprite2D] = [$Ojo1, $Ojo2]
@onready var _escala_ojo: Vector2 = $Ojo1.scale


func actualizar(direccion: Vector2, velocidad: Vector2, en_suelo: bool) -> void:
	_girar_hacia(atan2(direccion.x, direccion.y), 1.0 - exp(-velocidad_giro * get_physics_process_delta_time()))
	var altura := altura_suelo if en_suelo else altura_aire
	var corrimiento := (velocidad * corrimiento_por_velocidad).limit_length(corrimiento_max)
	var separacion_rad := deg_to_rad(separacion)
	_ubicar(_ojos[0], _angulo + separacion_rad, altura, corrimiento)
	_ubicar(_ojos[1], _angulo - separacion_rad, altura, corrimiento)
	var adelante := _ojos[0] if cos(_angulo + separacion_rad) > cos(_angulo - separacion_rad) else _ojos[1]
	move_child(adelante, -1)


func _ubicar(ojo: Sprite2D, longitud: float, altura: float, corrimiento: Vector2) -> void:
	var frente := cos(longitud)
	ojo.position = (Vector2(radio * sin(longitud), altura - profundidad * (1.0 - frente)) + corrimiento).limit_length(limite)
	ojo.scale.x = _escala_ojo.x * lerpf(ancho_minimo, 1.0, absf(frente))
	ojo.modulate.a = lerpf(alpha_detras, 1.0, smoothstep(-0.15, 0.15, frente))


func _girar_hacia(objetivo: float, peso: float) -> void:
	var diferencia := angle_difference(_angulo, objetivo)
	if absf(diferencia) > PI * 0.8 and absf(_angulo + diferencia) > PI + 0.01:
		diferencia -= signf(diferencia) * TAU
	_angulo = wrapf(_angulo + diferencia * peso, -PI, PI)
