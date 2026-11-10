extends Node2D
class_name AnilloBaba

@export var color_borde := Color("202024")
@export var color_baba := Color("457bd4")
@export_range(0, 30, 0.5, "suffix:px") var ancho_borde := 18.0
@export_range(0, 30, 0.5, "suffix:px") var ancho_baba := 11.0
@export var segmentos := 64
@export_range(0, 1, 0.01, "suffix:s") var duracion := 0.3
@export var gotas := 12
@export_range(0, 20, 0.5, "suffix:px") var radio_gota := 10.0
@export_range(0, 2, 0.05, "suffix:s") var duracion_gotas := 0.6

var _radio := 0.0
var _perspectiva := 1.0
var _avance := 0.0
var _alfa_gotas := 0.0
var _posiciones_gotas := PackedVector2Array()
var _tween: Tween


func _ready() -> void:
	hide()


func expandir(posicion: Vector2, radio: float, perspectiva: float) -> void:
	global_position = posicion
	_radio = radio
	_perspectiva = perspectiva
	_avance = 0.0
	_alfa_gotas = 0.0
	_ubicar_gotas()
	show()
	queue_redraw()
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_poner_avance, 0.0, 1.0, duracion).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tween.tween_method(_poner_gotas, 1.0, 0.0, duracion_gotas).set_ease(Tween.EASE_IN)
	_tween.tween_callback(hide)


func desactivar() -> void:
	if _tween:
		_tween.kill()
	hide()


func _ubicar_gotas() -> void:
	_posiciones_gotas.clear()
	var desfase := randf() * TAU
	for i in gotas:
		var angulo := desfase + TAU * (i + randf_range(-0.3, 0.3)) / gotas
		var distancia := _radio * randf_range(0.88, 1.04)
		_posiciones_gotas.append(Vector2(cos(angulo), sin(angulo) * _perspectiva) * distancia)


func _poner_avance(valor: float) -> void:
	_avance = valor
	queue_redraw()


func _poner_gotas(valor: float) -> void:
	_avance = 1.0
	_alfa_gotas = valor
	queue_redraw()


func _draw() -> void:
	if _avance < 1.0:
		var puntos := Formas.elipse(_radio * _avance, _perspectiva, segmentos)
		puntos.append(puntos[0])
		draw_polyline(puntos, color_borde, ancho_borde, true)
		draw_polyline(puntos, color_baba, ancho_baba, true)
		return
	var tamano := radio_gota * lerpf(0.5, 1.0, _alfa_gotas)
	for posicion in _posiciones_gotas:
		draw_circle(posicion, tamano + 3.0, Color(color_borde, _alfa_gotas))
		draw_circle(posicion, tamano, Color(color_baba, _alfa_gotas))
