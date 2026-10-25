class_name Boomie
extends Control

@export var textura: Texture2D
@export_range(-180, 180, 1, "suffix:°") var rotacion := 50.0
@export var espejado := true
@export var textura_ojo: Texture2D
@export var ojos: Array[Vector2] = [Vector2(0.53, 0.277), Vector2(0.684, 0.341)]
@export_range(0.1, 3, 0.05) var escala_ojo := 0.92
@export_range(-90, 90, 1, "suffix:°") var inclinacion_ojos := 15.0
@export var color_ojo := Color("15152a")
@export_range(1, 20, 0.5, "suffix:px") var grosor_ojo := 6.0
@export_group("Mirada")
@export_range(0, 20, 0.5, "suffix:px") var mirada_max := 3.0
@export_range(0, 1, 0.05, "suffix:s") var duracion_mirada := 0.25
@export_group("Parpadeo")
@export var parpadeo := Vector2(2.5, 5.0)
@export_range(0, 0.5, 0.01, "suffix:s") var duracion_parpadeo := 0.12
@export_group("Festejo")
@export_range(0, 40, 1, "suffix:px") var salto_festejo := 12.0
@export_range(0, 1, 0.05, "suffix:s") var duracion_salto := 0.3
@export_group("Entrada")
@export_range(0, 2, 0.05, "suffix:s") var retraso_entrada := 0.3
@export_range(0, 2, 0.05, "suffix:s") var duracion_entrada := 0.5

var _contento := false
var _cerrado := false
var _proximo_parpadeo := 0.0
var _tween_mirada: Tween
var _tween_entrada: Tween
var _mirada := Vector2.ZERO:
	set(valor):
		_mirada = valor
		queue_redraw()
var _salto := 0.0:
	set(valor):
		_salto = valor
		queue_redraw()
var _llegada := 1.0:
	set(valor):
		_llegada = valor
		queue_redraw()


func _ready() -> void:
	_proximo_parpadeo = randf_range(parpadeo.x, parpadeo.y)


func _process(delta: float) -> void:
	if parpadeo.y <= 0.0 or _contento:
		return
	_proximo_parpadeo -= delta
	if _proximo_parpadeo <= 0.0:
		_parpadear()


func entrar(festejar_al_llegar := false) -> void:
	if _tween_entrada:
		_tween_entrada.kill()
	_llegada = 0.0
	await get_tree().process_frame
	_tween_entrada = create_tween()
	_tween_entrada.tween_interval(retraso_entrada)
	_tween_entrada.tween_property(self, "_llegada", 1.0, duracion_entrada).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if festejar_al_llegar:
		_tween_entrada.tween_callback(festejar)


func hablar() -> void:
	_contento = false
	var nueva := Vector2(randf_range(0.3, 1.0), randf_range(-0.7, 0.7)).limit_length(1.0) * mirada_max
	if _tween_mirada:
		_tween_mirada.kill()
	_tween_mirada = create_tween()
	_tween_mirada.tween_property(self, "_mirada", nueva, duracion_mirada).set_trans(Tween.TRANS_SINE)


func festejar() -> void:
	_contento = true
	_cerrado = false
	create_tween().tween_method(_poner_salto, 0.0, PI, duracion_salto)


func _poner_salto(fase: float) -> void:
	_salto = sin(fase) * salto_festejo


func _parpadear() -> void:
	_proximo_parpadeo = randf_range(parpadeo.x, parpadeo.y)
	_cerrado = true
	queue_redraw()
	await get_tree().create_timer(duracion_parpadeo, false).timeout
	_cerrado = false
	queue_redraw()


func _draw() -> void:
	var lado := minf(size.x, size.y)
	var centro_caja := size / 2.0 + Vector2((_llegada - 1.0) * size.x * 1.5, -_salto)
	var giro := Vector2(-1.0 if espejado else 1.0, 1.0)
	draw_set_transform(centro_caja, deg_to_rad(rotacion), giro)
	draw_texture_rect(textura, Rect2(Vector2(-lado, -lado) / 2.0, Vector2(lado, lado)), false)
	var medida := textura_ojo.get_size() * lado / textura.get_width() * escala_ojo
	for ojo in ojos:
		var centro := centro_caja + (ojo - Vector2(0.5, 0.5)) * lado
		if _contento:
			draw_set_transform(centro, deg_to_rad(inclinacion_ojos))
			_dibujar_trazo([Vector2(-0.34, 0.1) * medida.x, Vector2(0.0, -0.2) * medida.x, Vector2(0.34, 0.1) * medida.x])
		elif _cerrado:
			draw_set_transform(centro + _mirada, deg_to_rad(inclinacion_ojos))
			_dibujar_trazo([Vector2(-0.25, 0.0) * medida.x, Vector2(0.25, 0.0) * medida.x])
		else:
			draw_set_transform(centro + _mirada, deg_to_rad(inclinacion_ojos), giro)
			draw_texture_rect(textura_ojo, Rect2(-medida / 2.0, medida), false)


func _dibujar_trazo(puntos: PackedVector2Array) -> void:
	draw_polyline(puntos, color_ojo, grosor_ojo, true)
	for punto in puntos:
		draw_circle(punto, grosor_ojo / 2.0, color_ojo, true, -1.0, true)
