extends Node2D
class_name DestelloBoomie

@export var color := Color(0.949, 0.698, 0.2)
@export var color_centro := Color(1.0, 0.965, 0.86)
@export_range(0, 200, 1, "suffix:px") var radio := 46.0
@export var rayos := 8
@export_range(0, 100, 1, "suffix:px") var largo_rayo := 24.0
@export_range(0, 20, 0.5, "suffix:px") var grosor_rayo := 5.0
@export_range(0, 1, 0.01, "suffix:s") var duracion := 0.4
@export_range(0, 1, 0.05) var desde_desvanecer := 0.35

var _progreso := 0.0
var _tween: Tween


func _ready() -> void:
	hide()


func explotar(posicion: Vector2) -> void:
	global_position = posicion
	_avanzar(0.0)
	show()
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_avanzar, 0.0, 1.0, duracion).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_callback(hide)


func desactivar() -> void:
	if _tween:
		_tween.kill()
	hide()


func _avanzar(progreso: float) -> void:
	_progreso = progreso
	queue_redraw()


func _draw() -> void:
	var alpha := 1.0 - smoothstep(desde_desvanecer, 1.0, _progreso)
	var actual := radio * lerpf(0.4, 1.0, _progreso)
	draw_circle(Vector2.ZERO, actual, Color(color, alpha * 0.9), true, -1.0, true)
	draw_circle(Vector2.ZERO, actual * 0.5, Color(color_centro, alpha), true, -1.0, true)
	for i in rayos:
		var direccion := Vector2.from_angle(TAU * i / rayos)
		var desde := direccion * actual * 1.2
		draw_line(desde, desde + direccion * largo_rayo * lerpf(1.0, 0.5, _progreso), Color(color, alpha), grosor_rayo, true)
