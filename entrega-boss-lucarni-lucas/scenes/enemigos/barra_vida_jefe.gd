extends Node2D

@export_range(0, 400, 1, "suffix:px") var ancho := 150.0
@export_range(0, 60, 1, "suffix:px") var alto := 18.0
@export_range(0, 10, 0.5, "suffix:px") var borde := 3.0
@export_range(0, 10, 0.5, "suffix:px") var margen := 4.0
@export_range(0, 20, 1, "suffix:px") var redondeo := 6
@export_range(0, 6, 0.5, "suffix:px") var grosor_division := 3.0
@export var color_fondo := Color(0.1, 0.1, 0.12, 0.85)
@export var color_borde := Color(0.05, 0.05, 0.06)
@export var color_vida := Color("#d63a3a")
@export var color_perdida := Color(1, 1, 1, 0.85)
@export_range(0, 2, 0.05, "suffix:s") var espera_perdida := 0.35
@export_range(0, 2, 0.05, "suffix:s") var caida_perdida := 0.3
@export_range(0, 2, 0.05, "suffix:s") var desvanecer := 0.3

var partes := 5
var vida := 1.0
var perdida := 1.0:
	set(valor):
		perdida = valor
		queue_redraw()

var _estilo := StyleBoxFlat.new()
var _tween: Tween


func _ready() -> void:
	_estilo.bg_color = color_fondo
	_estilo.border_color = color_borde
	_estilo.set_border_width_all(roundi(borde))
	_estilo.set_corner_radius_all(redondeo)


func reiniciar(cantidad_partes: int) -> void:
	partes = maxi(cantidad_partes, 1)
	if _tween:
		_tween.kill()
	vida = 1.0
	perdida = 1.0
	modulate.a = 1.0


func mostrar(actual: int, maxima: int) -> void:
	vida = clampf(float(actual) / maxf(maxima, 1), 0.0, 1.0)
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_interval(espera_perdida)
	_tween.tween_property(self, "perdida", vida, caida_perdida).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	queue_redraw()


func ocultar() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_interval(espera_perdida)
	_tween.tween_property(self, "perdida", vida, caida_perdida).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "modulate:a", 0.0, desvanecer)


func _draw() -> void:
	var caja := Rect2(-ancho / 2.0, -alto / 2.0, ancho, alto)
	_estilo.draw(get_canvas_item(), caja)
	var adentro := caja.grow(-margen)
	draw_rect(Rect2(adentro.position, Vector2(adentro.size.x * perdida, adentro.size.y)), color_perdida)
	draw_rect(Rect2(adentro.position, Vector2(adentro.size.x * vida, adentro.size.y)), color_vida)
	for i in range(1, partes):
		var x := adentro.position.x + adentro.size.x * i / partes
		draw_rect(Rect2(x - grosor_division / 2.0, adentro.position.y, grosor_division, adentro.size.y), color_borde)
