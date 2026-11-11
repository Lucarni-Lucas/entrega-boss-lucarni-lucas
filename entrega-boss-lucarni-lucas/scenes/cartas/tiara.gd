extends Node2D
class_name Tiara

enum Fase { QUIETA, ROTA, VUELVE }

@export var textura: Texture2D
@export var textura_trozo: Texture2D
@export_range(0, 200, 1, "suffix:px") var ancho := 56.0
@export_range(0, 200, 1, "suffix:px") var altura := 60.0
@export var color_borde := Color("141416")

@export_group("Al romperse")
@export_range(0, 1, 0.01, "suffix:s") var duracion_destello := 0.1
@export_range(0, 2, 0.01, "suffix:s") var duracion_trozos := 0.4
@export var trozos := 6
@export_range(0, 50, 1, "suffix:px") var alto_trozo := 22.0
@export_range(0, 1000, 10, "suffix:px/s") var velocidad_trozos := 260.0
@export_range(0, 3000, 10, "suffix:px/s²") var gravedad_trozos := 900.0

@export_group("Al volver")
@export_range(0, 2, 0.01, "suffix:s") var duracion_vuelta := 0.6
@export_range(0, 1, 0.01, "suffix:s") var duracion_salto := 0.15
@export_range(0, 1, 0.01, "suffix:s") var inicio_desvanecer := 0.3
@export_range(0, 1, 0.05) var escala_inicial := 0.5
@export_range(1, 2, 0.05) var escala_salto := 1.15
@export_range(0, 50, 1, "suffix:px") var subida := 12.0
@export var brillitos := 3
@export_range(0, 30, 0.5, "suffix:px") var radio_brillito := 11.0

var jugador: Player
var fase := Fase.QUIETA
var _tiempo := 0.0
var _trozos: Array[Dictionary] = []
var _brillitos := PackedVector2Array()


func _ready() -> void:
	top_level = true
	_quedar_quieta()


func romper() -> void:
	_empezar(Fase.ROTA)
	_trozos.clear()
	var cabeza := _cabeza()
	for i in trozos:
		var angulo := lerpf(-PI * 0.85, -PI * 0.15, (i + randf()) / trozos)
		_trozos.append({
			"posicion": cabeza + Vector2(randf_range(-0.4, 0.4) * ancho, -randf() * ancho * 0.6),
			"velocidad": Vector2.from_angle(angulo) * velocidad_trozos * randf_range(0.6, 1.1),
			"angulo": randf() * TAU,
			"giro": randf_range(-10.0, 10.0),
		})


func volver() -> void:
	_empezar(Fase.VUELVE)
	_brillitos.clear()
	for i in brillitos:
		var angulo := -PI * (0.15 + 0.7 * (i + randf_range(0.2, 0.8)) / brillitos)
		_brillitos.append(Vector2.from_angle(angulo) * ancho * randf_range(0.55, 0.8))


func desactivar() -> void:
	_quedar_quieta()


func _empezar(nueva: Fase) -> void:
	fase = nueva
	_tiempo = 0.0
	show()
	set_process(true)
	queue_redraw()


func _quedar_quieta() -> void:
	fase = Fase.QUIETA
	hide()
	set_process(false)


func _process(delta: float) -> void:
	_tiempo += delta
	if fase == Fase.ROTA:
		if _tiempo >= duracion_destello + duracion_trozos:
			_quedar_quieta()
			return
		if _tiempo >= duracion_destello:
			for trozo in _trozos:
				var velocidad: Vector2 = trozo["velocidad"]
				velocidad.y += gravedad_trozos * delta
				trozo["velocidad"] = velocidad
				trozo["posicion"] = (trozo["posicion"] as Vector2) + velocidad * delta
				trozo["angulo"] = (trozo["angulo"] as float) + (trozo["giro"] as float) * delta
	elif _tiempo >= duracion_vuelta:
		_quedar_quieta()
		return
	queue_redraw()


func _cabeza() -> Vector2:
	return jugador.global_position + Vector2(0, -jugador.z - altura)


func _draw() -> void:
	if fase == Fase.ROTA:
		if _tiempo < duracion_destello:
			_dibujar_tiara(_cabeza(), 1.0, Color(4, 4, 4))
			return
		var alfa := 1.0 - (_tiempo - duracion_destello) / duracion_trozos
		var tamano := Vector2(textura_trozo.get_width(), textura_trozo.get_height()) * alto_trozo / textura_trozo.get_height()
		for trozo in _trozos:
			draw_set_transform(trozo["posicion"], trozo["angulo"], Vector2.ONE * lerpf(0.6, 1.0, alfa))
			draw_texture_rect(textura_trozo, Rect2(-tamano * 0.5, tamano), false, Color(1, 1, 1, alfa))
		draw_set_transform(Vector2.ZERO)
	elif fase == Fase.VUELVE:
		var escala := escala_salto
		if _tiempo < duracion_salto:
			escala = lerpf(escala_inicial, escala_salto, ease(_tiempo / duracion_salto, 0.4))
		else:
			escala = lerpf(escala_salto, 1.0, clampf((_tiempo - duracion_salto) / duracion_salto, 0.0, 1.0))
		var desvanecer := clampf((_tiempo - inicio_desvanecer) / (duracion_vuelta - inicio_desvanecer), 0.0, 1.0)
		var cabeza := _cabeza() + Vector2(0, -subida * desvanecer)
		_dibujar_tiara(cabeza, escala, Color(1, 1, 1, 1.0 - desvanecer))
		var alfa_brillitos := 1.0 - clampf((_tiempo - duracion_salto) / (inicio_desvanecer - duracion_salto + 0.1), 0.0, 1.0)
		for i in _brillitos.size():
			var pulso := 0.7 + 0.3 * sin(_tiempo * 30.0 + i * 2.0)
			_dibujar_brillito(cabeza + _brillitos[i] + Vector2(0, -ancho * 0.4), radio_brillito * pulso, alfa_brillitos)


func _dibujar_tiara(base: Vector2, escala: float, color: Color) -> void:
	var tamano := Vector2(textura.get_width(), textura.get_height()) * ancho / textura.get_width() * escala
	draw_texture_rect(textura, Rect2(base - Vector2(tamano.x * 0.5, tamano.y), tamano), false, color)


func _dibujar_brillito(centro: Vector2, radio: float, alfa: float) -> void:
	if alfa <= 0.0:
		return
	var puntos := PackedVector2Array()
	for i in 8:
		var r := radio if i % 2 == 0 else radio * 0.3
		puntos.append(centro + Vector2.from_angle(i * PI / 4.0 - PI / 2.0) * r)
	draw_colored_polygon(puntos, Color(1, 1, 1, alfa))
	puntos.append(puntos[0])
	draw_polyline(puntos, Color(color_borde, alfa), 1.5, true)
