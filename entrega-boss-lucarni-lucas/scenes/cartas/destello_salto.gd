extends Node2D

@export var rayos := 8
@export_range(0, 200, 1, "suffix:px") var radio_base := 30.0
@export_range(0, 200, 1, "suffix:px") var recorrido := 45.0
@export_range(0, 100, 1, "suffix:px") var largo_inicial := 18.0
@export_range(0, 100, 1, "suffix:px") var largo_final := 8.0
@export_range(0, 2, 0.05) var subida := 0.9
@export_range(0, 20, 0.5, "suffix:px") var ancho := 7.0
@export_range(0, 20, 0.5, "suffix:px") var ancho_centro := 2.5
@export_range(0, 200, 1, "suffix:px") var brillo_inicial := 35.0
@export_range(0, 200, 1, "suffix:px") var brillo_final := 65.0
@export_range(0, 1, 0.05) var brillo_alfa := 0.4
@export_range(0.05, 2, 0.05, "suffix:s") var duracion := 0.3
@export_range(0.1, 1, 0.05) var perspectiva := 0.45
@export var color := Color("f2b233")
@export var color_centro := Color("fff3c4")

var _tiempo := 0.0
var _brillo: Polygon2D
var _lineas: Array[Line2D] = []


func _ready() -> void:
	_brillo = Polygon2D.new()
	_brillo.z_index = -2
	add_child(_brillo)
	for i in rayos:
		var adelante := sin(_angulo(i)) > 0.15
		for capa in [[ancho, color], [ancho_centro, color_centro]]:
			var linea := Line2D.new()
			linea.width = capa[0]
			linea.default_color = capa[1]
			linea.begin_cap_mode = Line2D.LINE_CAP_ROUND
			linea.end_cap_mode = Line2D.LINE_CAP_ROUND
			linea.z_index = 2 if adelante else -1
			add_child(linea)
			_lineas.append(linea)
	_dibujar(0.0)


func _process(delta: float) -> void:
	_tiempo += delta
	var avance := minf(_tiempo / duracion, 1.0)
	_dibujar(avance)
	if avance >= 1.0:
		queue_free()


func _angulo(indice: int) -> float:
	return TAU * (indice + 0.5) / rayos


func _dibujar(avance: float) -> void:
	var alfa := 1.0 - ease(avance, 2.2)
	var radio_brillo := lerpf(brillo_inicial, brillo_final, avance)
	var puntos := PackedVector2Array()
	for k in 32:
		var a := TAU * k / 32.0
		puntos.append(Vector2(cos(a), sin(a) * perspectiva) * radio_brillo)
	_brillo.polygon = puntos
	_brillo.color = Color(color, brillo_alfa * (1.0 - avance))
	var distancia := recorrido * ease(avance, 0.5)
	var largo := lerpf(largo_inicial, largo_final, avance)
	for i in rayos:
		var a := _angulo(i)
		var piso := Vector2(cos(a), sin(a) * perspectiva)
		var direccion := (piso + Vector2(0, -subida)).normalized()
		var inicio := piso * radio_base + direccion * distancia
		for capa in 2:
			var linea := _lineas[i * 2 + capa]
			linea.points = PackedVector2Array([inicio, inicio + direccion * largo])
			linea.modulate.a = alfa
