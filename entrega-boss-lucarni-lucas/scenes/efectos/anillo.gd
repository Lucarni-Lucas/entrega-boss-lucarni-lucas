extends Node2D

var _tween: Tween


func mostrar(posicion: Vector2, radio: float, params: EfectosParams) -> void:
	position = posicion
	modulate.a = 1.0
	visible = true
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_poner_radio, radio * params.anillo_radio_inicial, radio, params.anillo_expansion).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(self, "modulate:a", 0.0, params.anillo_desvanecer)
	_tween.tween_callback(hide)


func desactivar() -> void:
	if _tween:
		_tween.kill()
	hide()


func _poner_radio(radio: float) -> void:
	scale = Vector2.ONE * radio


func _draw() -> void:
	draw_rect(Rect2(-1.3, -1.0, 2.6, 2.0), Color.WHITE)
