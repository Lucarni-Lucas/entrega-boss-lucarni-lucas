extends Node2D
class_name ZonaLava

const _SHADER := preload("res://scenes/eventos/zona_lava.gdshader")

static var _material: ShaderMaterial

@export_range(0, 400, 5, "suffix:px") var radio := 160.0
@export var color := Color(0.94, 0.48, 0.1)
@export var color_centro := Color(1.0, 0.71, 0.23)
@export var color_borde := Color(0.08, 0.08, 0.09)
@export var color_burbuja := Color(1.0, 0.94, 0.7)
@export_range(0, 20, 0.5, "suffix:px") var grosor_borde := 6.0
@export_range(0, 1, 0.05) var tamano_centro := 0.65
@export var burbujas := 3
@export_range(0, 2, 0.05) var burbujas_por_segundo := 1.4
@export_range(0.05, 10, 0.05, "suffix:s") var aparicion := 4
@export var dano := 3
@export_range(0.05, 20, 0.05, "suffix:s") var intervalo := 1.1

var _perspectiva := 0.65
var _escala := 0.0
var _forma := Node2D.new()

@onready var _hitbox: Hitbox = $Hitbox
@onready var _poligono: CollisionPolygon2D = $Hitbox/CollisionPolygon2D


static func poner_tiempo(tiempo: float) -> void:
	if _material:
		_material.set_shader_parameter(&"tiempo", tiempo)


func _ready() -> void:
	add_child(_forma)
	_forma.scale = Vector2.ONE * 0.001
	_forma.draw.connect(_dibujar_forma)


func prender(posicion: Vector2, perspectiva: float) -> void:
	global_position = posicion
	modulate = Color(randf(), randf(), 1.0, 1.0)
	_perspectiva = perspectiva
	_poligono.polygon = Formas.elipse(radio, perspectiva, 24)
	_hitbox.dano = dano
	_hitbox.intervalo = intervalo
	_hitbox.activar()
	_preparar_material()
	_forma.material = _material
	_forma.queue_redraw()


func apagar(duracion: float) -> void:
	_hitbox.desactivar()
	create_tween().tween_property(self, "modulate:a", 0.0, duracion)


func _process(delta: float) -> void:
	_escala = minf(_escala + delta / aparicion, 1.0)
	_forma.scale = Vector2.ONE * maxf(_escala, 0.001)
	if _escala >= 1.0:
		set_process(false)
		_forma.queue_redraw()


func _preparar_material() -> void:
	if _material:
		return
	_material = ShaderMaterial.new()
	_material.shader = _SHADER
	_material.set_shader_parameter(&"radio", radio)
	_material.set_shader_parameter(&"perspectiva", _perspectiva)
	_material.set_shader_parameter(&"tamano_centro", tamano_centro)
	_material.set_shader_parameter(&"grosor_borde", grosor_borde)
	_material.set_shader_parameter(&"burbujas", burbujas)
	_material.set_shader_parameter(&"burbujas_por_segundo", burbujas_por_segundo)
	_material.set_shader_parameter(&"color_lava", color)
	_material.set_shader_parameter(&"color_centro", color_centro)
	_material.set_shader_parameter(&"color_borde", color_borde)
	_material.set_shader_parameter(&"color_burbuja", color_burbuja)


func _dibujar_forma() -> void:
	var margen := grosor_borde + 2.0 if _escala >= 1.0 else radio * 0.5
	var mitad := Vector2(radio + margen, radio * _perspectiva + margen)
	_forma.draw_rect(Rect2(-mitad, mitad * 2.0), Color.WHITE)
