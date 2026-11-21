extends Node2D
class_name OndaFreno

@export var color := Color("8fb0ea")
@export var color_borde := Color("202024")
@export_range(0, 30, 0.5, "suffix:px") var ancho := 4.0
@export_range(0, 40, 0.5, "suffix:px") var ancho_borde := 7.0
@export_range(0, 10000, 50, "suffix:px/s") var velocidad := 2200.0
@export_range(0, 6000, 50, "suffix:px") var radio_max := 3400.0
@export_range(0, 1, 0.05) var desvanecer_desde := 0.4
@export_group("Estela")
@export_range(0, 800, 10, "suffix:px") var largo_estela := 260.0
@export_range(0, 1, 0.05) var alfa_estela := 0.45
@export_group("Ecos")
@export var ecos := 2
@export_range(0, 300, 5, "suffix:px") var separacion_ecos := 70.0
@export_range(0, 30, 0.5, "suffix:px") var ancho_ecos := 4.8
@export_group("Marcas")
@export var marcas := 60
@export_range(0, 80, 1, "suffix:px") var largo_marca := 22.0
@export_range(0, 30, 0.5, "suffix:px") var ancho_marca := 4.8
@export_range(0, 40, 0.5, "suffix:px") var ancho_borde_marca := 8.4
@export_range(0, 6, 0.05, "suffix:rad/s") var giro_marcas := 1.2

var radio := 0.0
var _perspectiva := 1.0
var _pendientes: Array[Enemigo] = []
var _al_alcanzar: Callable
var _tiempo := 0.0
var _material: ShaderMaterial


func _ready() -> void:
	_material = material as ShaderMaterial
	for nombre in ["color", "color_borde", "ancho", "ancho_borde", "largo_estela", "alfa_estela", "ecos", "separacion_ecos", "ancho_ecos", "marcas", "largo_marca", "ancho_marca", "ancho_borde_marca"]:
		_material.set_shader_parameter(nombre, get(nombre))
	apagar()


func lanzar(centro: Vector2, perspectiva: float, enemigos: Array[Enemigo], al_alcanzar: Callable) -> void:
	global_position = centro
	_perspectiva = perspectiva
	_material.set_shader_parameter(&"perspectiva", perspectiva)
	var cantidad := enemigos.size()
	var claves := PackedInt64Array()
	for i in cantidad:
		claves.append(int(_distancia(enemigos[i])) * cantidad + i)
	claves.sort()
	_pendientes.clear()
	for i in range(cantidad - 1, -1, -1):
		_pendientes.append(enemigos[claves[i] % cantidad])
	_al_alcanzar = al_alcanzar
	radio = 0.0
	_tiempo = 0.0
	_actualizar()
	show()
	set_physics_process(true)


func precalentar(centro: Vector2) -> void:
	global_position = centro
	radio = largo_estela
	modulate.a = 0.01
	_actualizar()
	show()
	for i in 2:
		await get_tree().process_frame
	modulate.a = 1.0
	if not is_physics_processing():
		hide()


func activa() -> bool:
	return visible and is_physics_processing()


func apagar() -> void:
	_pendientes.clear()
	hide()
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	radio += velocidad * delta
	_tiempo += delta
	while not _pendientes.is_empty():
		var enemigo: Enemigo = _pendientes.back()
		if is_instance_valid(enemigo) and not enemigo.muerto:
			if radio < radio_max and _distancia(enemigo) > radio:
				break
			_al_alcanzar.call(enemigo)
		_pendientes.pop_back()
	if radio >= radio_max:
		apagar()
		return
	_actualizar()


func _distancia(enemigo: Enemigo) -> float:
	var d := enemigo.global_position - global_position
	return Vector2(d.x, d.y / _perspectiva).length()


func _actualizar() -> void:
	_material.set_shader_parameter(&"radio", radio)
	_material.set_shader_parameter(&"alfa", 1.0 - clampf((radio / radio_max - desvanecer_desde) / (1.0 - desvanecer_desde), 0.0, 1.0))
	_material.set_shader_parameter(&"giro", _tiempo * giro_marcas)
	queue_redraw()


func _draw() -> void:
	var borde := radio + largo_marca + ancho_borde_marca + 4.0
	draw_rect(Rect2(-borde, -borde * _perspectiva, borde * 2.0, borde * 2.0 * _perspectiva), Color.WHITE)
