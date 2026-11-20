extends Node2D
class_name ZonaRompePisos

const _SHADER := preload("res://scenes/cartas/rompe_pisos.gdshader")
const RADIO_DIBUJO := 100.0

static var _material: ShaderMaterial

@export var color_borde := Color("202024")
@export var color_hoyo := Color("3a3a40")
@export var color_sombra := Color("26262b")
@export var color_labio := Color("7a7a80")
@export_range(0, 20, 0.5, "suffix:px") var grosor_borde := 4.0
@export_range(0, 20, 0.5, "suffix:px") var grosor_grieta := 4.5
@export var grietas := 7
@export_range(0, 1, 0.05) var largo_grieta := 0.6
@export_range(0, 0.3, 0.01) var irregularidad := 0.12
@export_range(0, 1, 0.01, "suffix:s") var aparecer := 0.08
@export_range(0, 1, 0.01, "suffix:s") var desvanecer := 0.35

var radio := 0.0
var _perspectiva := 1.0
var _duracion := 0.0
var _restante := 0.0
var _forma := Node2D.new()


func _ready() -> void:
	top_level = true
	add_child(_forma)
	_forma.draw.connect(_dibujar_forma)
	_apagar()


func abrir(posicion: Vector2, nuevo_radio: float, perspectiva: float, duracion: float) -> void:
	global_position = posicion
	radio = nuevo_radio
	_perspectiva = perspectiva
	_duracion = duracion
	_restante = duracion
	if _forma.material == null:
		_preparar_material()
		_forma.material = _material
		_forma.queue_redraw()
	modulate = Color(randf(), randf(), 1.0, 1.0)
	_escalar(0.0)
	show()
	set_process(true)


func activa() -> bool:
	return _restante > 0.0


func cerrar() -> void:
	_restante = 0.0
	_apagar()


func contiene(punto: Vector2) -> bool:
	var d := punto - global_position
	return Vector2(d.x, d.y / _perspectiva).length() <= radio


func _apagar() -> void:
	hide()
	set_process(false)


func _process(delta: float) -> void:
	_restante -= delta
	if _restante <= 0.0:
		_apagar()
		return
	modulate.a = clampf(_restante / desvanecer, 0.0, 1.0)
	_escalar(_duracion - _restante)


func _escalar(transcurrido: float) -> void:
	scale = Vector2.ONE * radio / RADIO_DIBUJO * lerpf(0.7, 1.0, clampf(transcurrido / aparecer, 0.0, 1.0))


func _dibujar_forma() -> void:
	var alcance := 1.0 + irregularidad + largo_grieta * 1.25
	var mitad := Vector2(RADIO_DIBUJO, RADIO_DIBUJO * _perspectiva) * alcance
	_forma.draw_rect(Rect2(-mitad, mitad * 2.0), Color.WHITE)


func _preparar_material() -> void:
	if _material:
		return
	_material = ShaderMaterial.new()
	_material.shader = _SHADER
	_material.set_shader_parameter(&"radio", RADIO_DIBUJO)
	_material.set_shader_parameter(&"perspectiva", _perspectiva)
	_material.set_shader_parameter(&"irregularidad", irregularidad)
	_material.set_shader_parameter(&"grosor_borde", grosor_borde)
	_material.set_shader_parameter(&"grosor_grieta", grosor_grieta)
	_material.set_shader_parameter(&"grietas", grietas)
	_material.set_shader_parameter(&"largo_grieta", largo_grieta)
	_material.set_shader_parameter(&"color_hoyo", color_hoyo)
	_material.set_shader_parameter(&"color_sombra", color_sombra)
	_material.set_shader_parameter(&"color_labio", color_labio)
	_material.set_shader_parameter(&"color_borde", color_borde)
