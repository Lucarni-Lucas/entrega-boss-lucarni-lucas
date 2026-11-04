extends Node2D
class_name ZonaLava

@export_range(0, 400, 5, "suffix:px") var radio := 160.0
@export var color := Color(0.94, 0.48, 0.1)
@export var color_centro := Color(1.0, 0.71, 0.23)
@export var color_borde := Color(0.08, 0.08, 0.09)
@export var color_burbuja := Color(1.0, 0.94, 0.7)
@export_range(0, 20, 0.5, "suffix:px") var grosor_borde := 6.0
@export_range(0, 1, 0.05) var tamano_centro := 0.65
@export var burbujas := 3
@export_range(0, 2, 0.05) var burbujas_por_segundo := 1.4
@export_range(0.05, 10, 0.05, "suffix:s") var aparicion := 4
@export var dano := 3
@export_range(0.05, 20, 0.05, "suffix:s") var intervalo := 15

var _perspectiva := 0.65
var _escala := 0.0
var _tiempo := 0.0
var _lugares: Array[Vector2] = []

@onready var _hitbox: Hitbox = $Hitbox
@onready var _poligono: CollisionPolygon2D = $Hitbox/CollisionPolygon2D


func prender(posicion: Vector2, perspectiva: float) -> void:
	global_position = posicion
	_perspectiva = perspectiva
	_poligono.polygon = Formas.elipse(radio, perspectiva, 24)
	_hitbox.dano = dano
	_hitbox.intervalo = intervalo
	_hitbox.activar()
	for i in burbujas:
		var angulo := randf() * TAU
		_lugares.append(Vector2(cos(angulo), sin(angulo) * perspectiva) * radio * tamano_centro * randf_range(0.2, 1.1))


func apagar(duracion: float) -> void:
	_hitbox.desactivar()
	create_tween().tween_property(self, "modulate:a", 0.0, duracion)


func _process(delta: float) -> void:
	_tiempo += delta
	_escala = minf(_escala + delta / aparicion, 1.0)
	queue_redraw()


func _draw() -> void:
	var afuera := Formas.elipse(radio * _escala, _perspectiva, 32)
	draw_colored_polygon(afuera, color)
	draw_colored_polygon(Formas.elipse(radio * tamano_centro * _escala, _perspectiva, 32), color_centro)
	afuera.append(afuera[0])
	draw_polyline(afuera, color_borde, grosor_borde, true)
	for i in _lugares.size():
		var fase := fmod(_tiempo * burbujas_por_segundo + float(i) / _lugares.size(), 1.0)
		draw_arc(_lugares[i] * _escala, 3.0 + fase * 6.0, 0.0, TAU, 16, Color(color_burbuja, 1.0 - fase), 2.0, true)
