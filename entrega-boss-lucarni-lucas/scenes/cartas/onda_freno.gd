extends Node2D
class_name OndaFreno

@export var color := Color("8fb0ea")
@export var color_borde := Color("202024")
@export_range(0, 30, 0.5, "suffix:px") var ancho := 4.0
@export_range(0, 40, 0.5, "suffix:px") var ancho_borde := 7.0
@export_range(0, 10000, 50, "suffix:px/s") var velocidad := 2200.0
@export_range(0, 6000, 50, "suffix:px") var radio_max := 3400.0
@export_range(0, 1, 0.05) var desvanecer_desde := 0.4
@export var segmentos := 128
@export_group("Estela")
@export_range(0, 800, 10, "suffix:px") var largo_estela := 260.0
@export_range(0, 1, 0.05) var alfa_estela := 0.45
@export_group("Ecos")
@export var ecos := 2
@export_range(0, 300, 5, "suffix:px") var separacion_ecos := 70.0
@export_range(0, 30, 0.5, "suffix:px") var ancho_ecos := 4.8
@export_group("Marcas")
@export var marcas := 60
@export_range(0, 80, 1, "suffix:px") var largo_marca := 22.0
@export_range(0, 30, 0.5, "suffix:px") var ancho_marca := 4.8
@export_range(0, 40, 0.5, "suffix:px") var ancho_borde_marca := 8.4
@export_range(0, 6, 0.05, "suffix:rad/s") var giro_marcas := 1.2

var radio := 0.0
var _perspectiva := 1.0
var _pendientes: Array[Enemigo] = []
var _al_alcanzar: Callable
var _tiempo := 0.0


func _ready() -> void:
	apagar()


func lanzar(centro: Vector2, perspectiva: float, enemigos: Array[Enemigo], al_alcanzar: Callable) -> void:
	global_position = centro
	_perspectiva = perspectiva
	_pendientes = enemigos
	_al_alcanzar = al_alcanzar
	radio = 0.0
	_tiempo = 0.0
	show()
	set_physics_process(true)
	queue_redraw()


func activa() -> bool:
	return visible


func apagar() -> void:
	_pendientes.clear()
	hide()
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	radio += velocidad * delta
	_tiempo += delta
	for i in range(_pendientes.size() - 1, -1, -1):
		var enemigo := _pendientes[i]
		if not is_instance_valid(enemigo) or enemigo.muerto:
			_pendientes.remove_at(i)
		elif radio >= radio_max or _distancia(enemigo) <= radio:
			_al_alcanzar.call(enemigo)
			_pendientes.remove_at(i)
	if radio >= radio_max:
		apagar()
	queue_redraw()


func _distancia(enemigo: Enemigo) -> float:
	var d := enemigo.global_position - global_position
	return Vector2(d.x, d.y / _perspectiva).length()


func _punto(angulo: float, distancia: float) -> Vector2:
	return Vector2(cos(angulo), sin(angulo) * _perspectiva) * distancia


func _draw() -> void:
	var alfa := 1.0 - clampf((radio / radio_max - desvanecer_desde) / (1.0 - desvanecer_desde), 0.0, 1.0)
	if largo_estela > 0.0:
		_dibujar_estela(alfa)
	for k in range(1, ecos + 1):
		var distancia := radio - separacion_ecos * k
		if distancia > 0.0:
			_dibujar_anillo(distancia, ancho_ecos, 0.0, alfa * (1.0 - float(k) / (ecos + 1)))
	_dibujar_anillo(radio, ancho, ancho_borde, alfa)
	_dibujar_marcas(alfa)


func _dibujar_anillo(distancia: float, grosor: float, grosor_borde: float, alfa: float) -> void:
	var puntos := Formas.elipse(distancia, _perspectiva, segmentos)
	puntos.append(puntos[0])
	if grosor_borde > 0.0:
		draw_polyline(puntos, Color(color_borde, alfa), grosor_borde, true)
	draw_polyline(puntos, Color(color, alfa), grosor, true)


func _dibujar_estela(alfa: float) -> void:
	var afuera := Formas.elipse(radio, _perspectiva, segmentos)
	var adentro := Formas.elipse(maxf(radio - largo_estela, 0.0), _perspectiva, segmentos)
	var fuerte := Color(color, alfa_estela * alfa)
	var nada := Color(color, 0.0)
	var colores := PackedColorArray([fuerte, fuerte, nada, nada])
	for i in segmentos:
		var j := (i + 1) % segmentos
		draw_polygon(PackedVector2Array([afuera[i], afuera[j], adentro[j], adentro[i]]), colores)


func _dibujar_marcas(alfa: float) -> void:
	for i in marcas:
		var angulo := TAU * i / marcas + _tiempo * giro_marcas
		var largo := largo_marca * (1.6 if i % 5 == 0 else 1.0)
		var desde := _punto(angulo, radio - largo * 0.5)
		var hasta := _punto(angulo, radio + largo * 0.5)
		draw_line(desde, hasta, Color(color_borde, alfa), ancho_borde_marca, true)
		draw_line(desde, hasta, Color(color, alfa), ancho_marca, true)
