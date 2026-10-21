extends Node2D

var _radio := 0.0
var _perspectiva := 1.0
var _params: EfectosParams
var _tween: Tween


func mostrar(posicion: Vector2, radio: float, perspectiva: float, params: EfectosParams) -> void:
	position = posicion
	_perspectiva = perspectiva
	_params = params
	modulate.a = 1.0
	visible = true
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_poner_radio, radio * params.anillo_radio_inicial, radio, params.anillo_expansion).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(self, "modulate:a", 0.0, params.anillo_desvanecer)
	_tween.tween_callback(hide)


func _poner_radio(radio: float) -> void:
	_radio = radio
	queue_redraw()


func _draw() -> void:
	if _params == null:
		return
	var puntos := Formas.elipse(_radio, _perspectiva, 48)
	puntos.append(puntos[0])
	draw_polyline(puntos, _params.anillo_color_borde, _params.anillo_ancho_borde, true)
	draw_polyline(puntos, _params.anillo_color_interior, _params.anillo_ancho_interior, true)
