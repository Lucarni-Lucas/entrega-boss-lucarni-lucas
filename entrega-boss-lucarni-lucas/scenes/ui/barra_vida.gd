extends Control

const SUAVIZADO := 0.6

@export var puntos_por_tramo := 5
@export_range(0, 40, 1, "suffix:px") var separacion := 10.0
@export_range(0, 40, 1, "suffix:px") var inclinacion := 10.0
@export_range(1, 100, 1, "suffix:px") var alto_barra := 36.0
@export_range(0, 40, 1, "suffix:px") var alto_brillo := 6.0
@export_range(0, 20, 1, "suffix:px") var margen_fondo := 6.0
@export_range(0, 10, 0.5, "suffix:px") var grosor_division := 2.0
@export var color_fondo := Color(0.08, 0.08, 0.094, 0.85)
@export var color_vacio := Color("2c2c33")
@export var color_lleno := Color("d33333")
@export var color_brillo := Color(1, 0.45, 0.45, 0.55)
@export var color_rastro := Color("f2d6d6")
@export_range(0, 2, 0.05, "suffix:s") var espera_rastro := 0.35
@export var velocidad_rastro := 15.0

@export_group("Energía")
@export var icono_energia: Texture2D
@export_range(0, 40, 1, "suffix:px") var alto_energia := 8.0
@export_range(0, 40, 1, "suffix:px") var separacion_energia := 12.0
@export_range(0, 80, 1, "suffix:px") var tamano_icono := 26.0
@export_range(0, 40, 1, "suffix:px") var separacion_icono := 8.0
@export_range(0, 10, 0.5, "suffix:px") var margen_zona := 2.5
@export_range(0, 5, 0.5, "suffix:px") var grosor_zona := 1.5
@export var color_energia := Color.WHITE
@export var color_energia_lista := Color("f2b233")
@export var color_zona := Color("a8a8b3")
@export_range(0, 6, 0.5, "suffix:px") var borde_oscuro := 2.0
@export_range(0, 10, 0.5, "suffix:px") var margen_resaltado := 5.0
@export_range(0, 5, 0.5, "suffix:px") var grosor_resaltado := 2.5
@export_range(0.1, 5, 0.1, "suffix:Hz") var frecuencia_resaltado := 1.5
@export_range(0, 1, 0.05) var escala_resaltado := 0.2

var vida := 0
var maximo := 1
var energia := 0.0
var marca_energia := 1.0
var resaltar_energia := false:
	set(valor):
		resaltar_energia = valor
		_tiempo_resaltado = 0.0
		_marco.queue_redraw()

var _rastro := 0.0
var _espera := 0.0
var _tiempo_resaltado := 0.0
var _relleno := Node2D.new()
var _marco := Node2D.new()
var _puntos := PackedVector2Array()
var _colores := PackedColorArray()
var _indices := PackedInt32Array()


func _ready() -> void:
	add_child(_relleno)
	add_child(_marco)
	_relleno.draw.connect(_dibujar_relleno)
	_marco.draw.connect(_dibujar_marco)


func mostrar(actual: int, nuevo_maximo: int) -> void:
	if actual < vida:
		_rastro = maxf(_rastro, vida)
		_espera = espera_rastro
	else:
		_rastro = maxf(_rastro, actual)
	vida = actual
	if maxi(nuevo_maximo, 1) != maximo:
		maximo = maxi(nuevo_maximo, 1)
		_relleno.queue_redraw()
		_marco.queue_redraw()
	queue_redraw()


func mostrar_energia(nueva: float, marca: float) -> void:
	var estaba_lista := energia >= marca_energia
	var marca_cambio := marca != marca_energia
	energia = nueva
	marca_energia = marca
	_relleno.queue_redraw()
	if marca_cambio or (energia >= marca_energia) != estaba_lista:
		_marco.queue_redraw()


func _process(delta: float) -> void:
	if resaltar_energia:
		_tiempo_resaltado += delta
		_marco.queue_redraw()
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
	var margen := Vector2(margen_fondo, margen_fondo)
	_paralelogramo(Vector2(inclinacion, 0) - margen, _ancho_total() + margen_fondo * 2, alto_barra + margen_fondo * 2, color_fondo)
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
			_linea(arriba, arriba + Vector2(-inclinacion, alto_barra), color_fondo, grosor_division)
	_cuadro(_esquinas(_origen_energia(), _ancho_energia(), alto_energia), color_fondo, 0.0)
	_volcar(get_canvas_item())


func _dibujar_relleno() -> void:
	var ancho := _ancho_energia() * clampf(energia, 0.0, 1.0)
	if ancho <= 0.0:
		return
	var color := color_energia_lista if energia >= marca_energia else color_energia
	_relleno.draw_primitive(_expandir(_esquinas(_origen_energia(), ancho, alto_energia), 0.3), PackedColorArray([color]), PackedVector2Array())


func _dibujar_marco() -> void:
	var origen := _origen_energia()
	var ancho := _ancho_energia()
	var lista := energia >= marca_energia
	var zona := origen + Vector2(ancho * marca_energia + inclinacion * margen_zona / alto_barra, -margen_zona)
	var ancho_zona := ancho * (1.0 - marca_energia) + margen_zona
	_contorno(zona, ancho_zona, alto_energia + margen_zona * 2.0, color_fondo, grosor_zona + borde_oscuro * 2.0)
	_contorno(zona, ancho_zona, alto_energia + margen_zona * 2.0, color_energia_lista if lista else color_zona, grosor_zona)
	var pulso := 0.0
	if resaltar_energia:
		pulso = 0.5 - 0.5 * cos(_tiempo_resaltado * TAU * frecuencia_resaltado)
		var borde := origen + Vector2(inclinacion * margen_resaltado / alto_barra, -margen_resaltado)
		_contorno(borde - Vector2(margen_resaltado, 0), ancho + margen_resaltado * 2.0, alto_energia + margen_resaltado * 2.0, Color(color_energia_lista, pulso), grosor_resaltado)
	_volcar(_marco.get_canvas_item())
	if icono_energia:
		var tamano := Vector2.ONE * tamano_icono * (1.0 + escala_resaltado * pulso)
		var centro := origen + Vector2(ancho + separacion_icono + tamano_icono * 0.5, alto_energia * 0.5)
		var rect := Rect2(centro - tamano * 0.5, tamano)
		for i in 8:
			_marco.draw_texture_rect(icono_energia, Rect2(rect.position + Vector2.from_angle(TAU * i / 8.0) * borde_oscuro, tamano), false, color_fondo)
		_marco.draw_texture_rect(icono_energia, rect, false, color_energia_lista if lista else color_zona)


func _ancho_total() -> float:
	var tramos := ceili(float(maximo) / puntos_por_tramo)
	var ancho_tramo := (size.x - inclinacion - separacion * (tramos - 1)) / tramos
	return ancho_tramo * tramos + separacion * (tramos - 1)


func _origen_energia() -> Vector2:
	var arriba := alto_barra + separacion_energia
	return Vector2(inclinacion - arriba * inclinacion / alto_barra, arriba)


func _ancho_energia() -> float:
	var corrimiento_fondo := margen_fondo * (1.0 + inclinacion / alto_barra)
	return inclinacion * alto_energia / alto_barra + _ancho_total() - tamano_icono - separacion_icono - _origen_energia().x + corrimiento_fondo


func _paralelogramo(origen: Vector2, ancho: float, alto: float, color: Color) -> void:
	if ancho > 0.0:
		_cuadro(_esquinas(origen, ancho, alto), color, 0.5)


func _linea(desde: Vector2, hasta: Vector2, color: Color, grosor: float) -> void:
	var direccion := (hasta - desde).normalized()
	var costado := Vector2(direccion.y, -direccion.x) * grosor * 0.5
	_cuadro(PackedVector2Array([desde - costado, desde + costado, hasta + costado, hasta - costado]), color, 0.0)


func _contorno(origen: Vector2, ancho: float, alto: float, color: Color, grosor: float) -> void:
	if ancho <= 0.0:
		return
	var esquinas := _esquinas(origen, ancho, alto)
	var capas: Array[PackedVector2Array] = [
		_expandir(esquinas, grosor * 0.5 + SUAVIZADO),
		_expandir(esquinas, grosor * 0.5),
		_expandir(esquinas, -grosor * 0.5),
		_expandir(esquinas, -grosor * 0.5 - SUAVIZADO),
	]
	var base := _puntos.size()
	for capa in 4:
		_puntos.append_array(capas[capa])
		for i in 4:
			_colores.append(color if capa == 1 or capa == 2 else Color(color, 0.0))
	for capa in 3:
		for i in 4:
			_unir(base + capa * 4 + i, base + capa * 4 + (i + 1) % 4, base + (capa + 1) * 4 + (i + 1) % 4, base + (capa + 1) * 4 + i)


func _cuadro(esquinas: PackedVector2Array, color: Color, extra: float) -> void:
	var base := _puntos.size()
	_puntos.append_array(_expandir(esquinas, extra))
	_puntos.append_array(_expandir(esquinas, extra + SUAVIZADO))
	for i in 4:
		_colores.append(color)
	for i in 4:
		_colores.append(Color(color, 0.0))
	_unir(base, base + 1, base + 2, base + 3)
	for i in 4:
		_unir(base + i, base + (i + 1) % 4, base + 4 + (i + 1) % 4, base + 4 + i)


func _unir(a: int, b: int, c: int, d: int) -> void:
	_indices.append_array(PackedInt32Array([a, b, c, a, c, d]))


func _expandir(esquinas: PackedVector2Array, distancia: float) -> PackedVector2Array:
	var salida := PackedVector2Array()
	for i in esquinas.size():
		var antes := (esquinas[i] - esquinas[i - 1]).normalized()
		var despues := (esquinas[(i + 1) % esquinas.size()] - esquinas[i]).normalized()
		var normal_antes := Vector2(antes.y, -antes.x)
		var normal_despues := Vector2(despues.y, -despues.x)
		salida.append(esquinas[i] + (normal_antes + normal_despues) * distancia / (1.0 + normal_antes.dot(normal_despues)))
	return salida


func _volcar(lienzo: RID) -> void:
	if not _indices.is_empty():
		RenderingServer.canvas_item_add_triangle_array(lienzo, _indices, _puntos, _colores)
	_puntos.clear()
	_colores.clear()
	_indices.clear()


func _esquinas(origen: Vector2, ancho: float, alto: float) -> PackedVector2Array:
	var corrimiento := inclinacion * alto / alto_barra
	return PackedVector2Array([origen, origen + Vector2(ancho, 0), origen + Vector2(ancho - corrimiento, alto), origen + Vector2(-corrimiento, alto)])
