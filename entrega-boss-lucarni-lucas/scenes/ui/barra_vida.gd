extends Control

@export var puntos_por_tramo := 5
@export_range(0, 40, 1, "suffix:px") var separacion := 10.0
@export_range(0, 40, 1, "suffix:px") var inclinacion := 10.0
@export_range(1, 100, 1, "suffix:px") var alto_barra := 36.0
@export_range(0, 40, 1, "suffix:px") var alto_brillo := 6.0
@export_range(0, 20, 1, "suffix:px") var margen_fondo := 6.0
@export_range(0, 10, 0.5, "suffix:px") var grosor_division := 2.0
@export_range(0, 40, 1, "suffix:px") var alto_curacion := 8.0
@export_range(0, 40, 1, "suffix:px") var separacion_curacion := 12.0
@export var color_fondo := Color(0.08, 0.08, 0.094, 0.85)
@export var color_vacio := Color("2c2c33")
@export var color_lleno := Color("d33333")
@export var color_brillo := Color(1, 0.45, 0.45, 0.55)
@export var color_rastro := Color("f2d6d6")
@export var color_curacion := Color.WHITE
@export_range(0, 2, 0.05, "suffix:s") var espera_rastro := 0.35
@export var velocidad_rastro := 15.0

var vida := 0
var maximo := 1
var curacion := 0.0:
	set(valor):
		curacion = valor
		queue_redraw()

var _rastro := 0.0
var _espera := 0.0


func mostrar(actual: int, nuevo_maximo: int) -> void:
	if actual < vida:
		_rastro = maxf(_rastro, vida)
		_espera = espera_rastro
	else:
		_rastro = maxf(_rastro, actual)
	vida = actual
	maximo = maxi(nuevo_maximo, 1)
	queue_redraw()


func _process(delta: float) -> void:
	if _rastro <= vida:
		return
	if _espera > 0.0:
		_espera -= delta
		return
	_rastro = maxf(vida, _rastro - velocidad_rastro * delta)
	queue_redraw()


func _draw() -> void:
	var tramos := ceili(float(maximo) / puntos_por_tramo)
	var ancho_tramo := (size.x - inclinacion - separacion * (tramos - 1)) / tramos
	var ancho_total := ancho_tramo * tramos + separacion * (tramos - 1)
	var margen := Vector2(margen_fondo, margen_fondo)
	_paralelogramo(Vector2(inclinacion, 0) - margen, ancho_total + margen_fondo * 2, alto_barra + margen_fondo * 2, color_fondo)
	for tramo in tramos:
		var origen := Vector2(inclinacion + tramo * (ancho_tramo + separacion), 0)
		var desde := tramo * puntos_por_tramo
		var capacidad := mini(puntos_por_tramo, maximo - desde)
		var ancho_punto := ancho_tramo / puntos_por_tramo
		_paralelogramo(origen, ancho_punto * capacidad, alto_barra, color_vacio)
		var rastro := clampf(_rastro - desde, 0.0, capacidad)
		var lleno := clampf(vida - desde, 0.0, capacidad)
		if rastro > 0.0:
			_paralelogramo(origen, ancho_punto * rastro, alto_barra, color_rastro)
		if lleno > 0.0:
			_paralelogramo(origen, ancho_punto * lleno, alto_barra, color_lleno)
			_paralelogramo(origen, ancho_punto * lleno, alto_brillo, color_brillo)
		for punto in range(1, capacidad):
			var arriba := origen + Vector2(ancho_punto * punto, 0)
			draw_line(arriba, arriba + Vector2(-inclinacion, alto_barra), color_fondo, grosor_division, true)
	var origen_curacion := Vector2(inclinacion * alto_curacion / alto_barra, alto_barra + separacion_curacion)
	_paralelogramo(origen_curacion, ancho_total, alto_curacion, color_fondo)
	_paralelogramo(origen_curacion, ancho_total * clampf(curacion, 0.0, 1.0), alto_curacion, color_curacion)


func _paralelogramo(origen: Vector2, ancho: float, alto: float, color: Color) -> void:
	if ancho <= 0.0:
		return
	var corrimiento := inclinacion * alto / alto_barra
	var puntos := PackedVector2Array([origen, origen + Vector2(ancho, 0), origen + Vector2(ancho - corrimiento, alto), origen + Vector2(-corrimiento, alto)])
	draw_colored_polygon(puntos, color)
	puntos.append(origen)
	draw_polyline(puntos, color, 1.0, true)
