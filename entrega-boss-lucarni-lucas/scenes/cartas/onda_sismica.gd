extends Node2D
class_name OndaSismica

@export var color_borde := Color("202024")
@export var color_interior := Color("f5f2e3")
@export_range(0, 20, 0.5, "suffix:px") var ancho_borde := 8.0
@export_range(0, 20, 0.5, "suffix:px") var ancho_interior := 4.0
@export_range(0, 100, 1, "suffix:px") var radio_inicial := 22.0
@export_range(0, 100, 1, "suffix:px") var radio_final := 46.0
@export var arcos := 3
@export_range(0, 50, 1, "suffix:px") var separacion := 18.0
@export_range(0, 1, 0.05) var achatado := 0.55
@export_range(0, 0.5, 0.01, "suffix:s") var desvanecer := 0.08

var _altura := 0.0
var _avance := 0.0
var _perspectiva := 1.0
var _tween: Tween


func _ready() -> void:
	hide()


func bajar(posicion: Vector2, altura: float, duracion: float, perspectiva: float, al_llegar: Callable) -> void:
	global_position = posicion
	_altura = altura
	_perspectiva = perspectiva
	_avance = 0.0
	modulate.a = 1.0
	show()
	queue_redraw()
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_poner_avance, 0.0, 1.0, duracion).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	_tween.tween_callback(al_llegar)
	_tween.tween_property(self, "modulate:a", 0.0, desvanecer)
	_tween.tween_callback(hide)


func _poner_avance(valor: float) -> void:
	_avance = valor
	queue_redraw()


func _draw() -> void:
	var radio := lerpf(radio_inicial, radio_final, _avance)
	var frente := -_altura * (1.0 - _avance)
	for i in arcos:
		var r := radio * (1.0 - 0.2 * i)
		var y := frente - separacion * i * _avance
		var puntos := PackedVector2Array()
		for k in 17:
			var angulo := PI * k / 16.0
			puntos.append(Vector2(cos(angulo) * r, y + sin(angulo) * r * achatado * _perspectiva))
		var alfa := 1.0 - float(i) / arcos
		draw_polyline(puntos, Color(color_borde, alfa), ancho_borde, true)
		draw_polyline(puntos, Color(color_interior, alfa), ancho_interior, true)
