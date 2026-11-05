extends Node2D
class_name Electricidad

@export var color := Color(0.5, 0.86, 1.0)
@export var color_nucleo := Color.WHITE
@export var cantidad := 4
@export_range(0, 100, 1, "suffix:px") var radio := 20.0
@export_range(0, 1, 0.05) var achatado := 0.5
@export_range(0, 40, 1, "suffix:px") var largo := 18.0
@export_range(0, 1, 0.05) var probabilidad := 0.8
@export_range(0.01, 0.5, 0.01, "suffix:s") var cada := 0.06
@export_range(0, 10, 0.5, "suffix:px") var grosor := 4.5
@export_range(0, 10, 0.5, "suffix:px") var grosor_nucleo := 2.0
@export_group("Ráfaga")
@export_range(0, 3, 0.05, "suffix:s") var duracion_rafaga := 0.3

var _tiempo := 0.0
var _rafaga := 0.0


func rafaga() -> void:
	_rafaga = duracion_rafaga
	show()


func apagar() -> void:
	_rafaga = 0.0
	hide()


func _process(delta: float) -> void:
	if _rafaga > 0.0:
		_rafaga -= delta
		if _rafaga <= 0.0:
			hide()
			return
	if not is_visible_in_tree():
		return
	_tiempo -= delta
	if _tiempo <= 0.0:
		_tiempo = cada
		queue_redraw()


func _draw() -> void:
	for i in cantidad:
		if randf() > probabilidad:
			continue
		var angulo := TAU * (i + randf()) / cantidad
		var afuera := Vector2(cos(angulo), sin(angulo) * achatado)
		var puntos := PackedVector2Array([afuera * radio])
		var costado := afuera.orthogonal()
		for paso in 3:
			var lado := 1.0 if paso % 2 == 0 else -1.0
			puntos.append(puntos[-1] + afuera * largo / 3.0 + costado * lado * largo * 0.3)
		draw_polyline(puntos, color, grosor)
		draw_polyline(puntos, color_nucleo, grosor_nucleo)
