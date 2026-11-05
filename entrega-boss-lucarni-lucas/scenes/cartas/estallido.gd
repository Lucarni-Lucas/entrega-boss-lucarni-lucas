extends Node2D
class_name Estallido

@export var textura_chispa: Texture2D
@export var cantidad_chispas := 12
@export var escala_chispa := 0.55
@export var color_chispa := Color(1.0, 0.72, 0.4)
@export var puntas := 9
@export_range(0, 1, 0.05) var hundimiento := 0.55
@export_range(0, 1, 0.05) var irregularidad := 0.15
@export_range(0, 1, 0.05) var tamano_estallido := 0.75
@export_range(0, 1, 0.05) var tamano_centro := 0.55
@export_range(0, 1, 0.01, "suffix:s") var duracion := 0.32

var _chispas: Array[Sprite2D] = []
var _forma: Array[float] = []
var _radio_forma := -1.0
var _perspectiva_forma := -1.0
var _signo := Vector2.ONE
var _tween: Tween

@onready var _relleno: Polygon2D = $Relleno
@onready var _centro: Polygon2D = $Centro
@onready var _borde: Line2D = $Borde


func _ready() -> void:
	for i in cantidad_chispas:
		var chispa := Sprite2D.new()
		chispa.texture = textura_chispa
		chispa.modulate = color_chispa
		add_child(chispa)
		_chispas.append(chispa)
	for i in puntas * 2:
		_forma.append((1.0 if i % 2 == 0 else hundimiento) * randf_range(1.0 - irregularidad, 1.0 + irregularidad))
	hide()


func explotar(posicion: Vector2, radio: float, perspectiva: float) -> void:
	_armar_forma(radio * tamano_estallido, perspectiva)
	_signo = Vector2(1.0 if randf() < 0.5 else -1.0, 1.0 if randf() < 0.5 else -1.0)
	global_position = posicion
	modulate.a = 1.0
	show()
	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel()
	_tween.tween_method(_poner_progreso, 0.3, 1.0, duracion * 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	for i in _chispas.size():
		var chispa := _chispas[i]
		var direccion := Vector2.from_angle(TAU * (i + randf()) / _chispas.size())
		chispa.position = Vector2.ZERO
		chispa.scale = Vector2.ONE * escala_chispa
		_tween.tween_property(chispa, "position", Vector2(direccion.x, direccion.y * perspectiva) * radio * randf_range(0.8, 1.05), duracion).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		_tween.tween_property(chispa, "scale", Vector2.ONE * escala_chispa * 0.3, duracion).set_ease(Tween.EASE_IN)
	_tween.tween_property(self, "modulate:a", 0.0, duracion * 0.5).set_delay(duracion * 0.5)
	_tween.chain().tween_callback(hide)


func desactivar() -> void:
	if _tween:
		_tween.kill()
	hide()


func _poner_progreso(progreso: float) -> void:
	var escala := _signo * progreso
	_relleno.scale = escala
	_centro.scale = escala
	_borde.scale = escala


func _armar_forma(radio: float, perspectiva: float) -> void:
	if radio == _radio_forma and perspectiva == _perspectiva_forma:
		return
	_radio_forma = radio
	_perspectiva_forma = perspectiva
	var puntos := PackedVector2Array()
	for i in _forma.size():
		var direccion := Vector2.from_angle(TAU * i / _forma.size())
		puntos.append(Vector2(direccion.x, direccion.y * perspectiva) * radio * _forma[i])
	_relleno.polygon = puntos
	_borde.points = puntos
	var centro := PackedVector2Array()
	for punto in puntos:
		centro.append(punto * tamano_centro)
	_centro.polygon = centro
