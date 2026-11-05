extends Node2D
class_name Rayo

@export var color := Color(0.5, 0.86, 1.0)
@export var color_nucleo := Color.WHITE
@export_range(0, 1, 0.01, "suffix:s") var duracion := 0.2
@export_range(0.01, 0.2, 0.01, "suffix:s") var cada := 0.03
@export_range(1, 20, 1) var quiebres := 6
@export_range(0, 40, 1, "suffix:px") var amplitud := 11.0
@export_range(0, 20, 0.5, "suffix:px") var grosor := 6.0
@export_range(0, 10, 0.5, "suffix:px") var grosor_nucleo := 2.5

var _puntos := PackedVector2Array()
var _restante := 0.0
var _hasta_quiebre := 0.0


func _ready() -> void:
	hide()


func descargar(puntos: PackedVector2Array) -> void:
	_puntos = puntos
	_restante = duracion
	_hasta_quiebre = 0.0
	modulate.a = 1.0
	show()
	queue_redraw()


func desactivar() -> void:
	_restante = 0.0
	hide()


func _process(delta: float) -> void:
	if not visible:
		return
	_restante -= delta
	if _restante <= 0.0:
		hide()
		return
	modulate.a = clampf(_restante / (duracion * 0.5), 0.0, 1.0)
	_hasta_quiebre -= delta
	if _hasta_quiebre <= 0.0:
		_hasta_quiebre = cada
		queue_redraw()


func _draw() -> void:
	for i in _puntos.size() - 1:
		var zigzag := _zigzag(_puntos[i], _puntos[i + 1])
		draw_polyline(zigzag, color, grosor)
		draw_polyline(zigzag, color_nucleo, grosor_nucleo)


func _zigzag(desde: Vector2, hasta: Vector2) -> PackedVector2Array:
	var puntos := PackedVector2Array([desde])
	var costado := (hasta - desde).normalized().orthogonal()
	for i in range(1, quiebres):
		var t := float(i) / quiebres
		puntos.append(desde.lerp(hasta, t) + costado * randf_range(-amplitud, amplitud))
	puntos.append(hasta)
	return puntos
