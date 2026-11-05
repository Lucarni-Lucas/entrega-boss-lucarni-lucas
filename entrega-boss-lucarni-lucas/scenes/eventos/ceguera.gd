extends Evento

@export_range(0, 2000, 10, "suffix:px") var radio := 500.0
@export_range(0, 1000, 10, "suffix:px") var borde := 250.0
@export_range(0, 1, 0.01) var oscuridad := 0.99
@export_range(0, 5, 0.1, "suffix:s") var transicion := 1.0
@export_range(0, 20000, 100, "suffix:px") var tamano := 8000.0

var fuerza := 0.0:
	set(valor):
		fuerza = valor
		material.set_shader_parameter("fuerza", valor)

var _jugador: Player
var _spawner: Spawner
var _tween: Tween


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group(Player.GRUPO) as Player
	_spawner = get_tree().get_first_node_in_group(Spawner.GRUPO) as Spawner
	material.set_shader_parameter("radio", radio)
	material.set_shader_parameter("borde", borde)
	material.set_shader_parameter("oscuridad", oscuridad)
	material.set_shader_parameter("perspectiva", _jugador.params.anim_perspectiva)
	fuerza = 0.0
	_seguir()
	_tween = create_tween()
	_tween.tween_property(self, "fuerza", 1.0, transicion)


func _process(_delta: float) -> void:
	_seguir()


func _draw() -> void:
	draw_rect(Rect2(-Vector2.ONE * tamano / 2.0, Vector2.ONE * tamano), Color.WHITE)


func terminar() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for marca: MarcaSpawn in _spawner.marcas():
		marca.oculta = false
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "fuerza", 0.0, transicion * fuerza)
	_tween.tween_callback(queue_free)


func _seguir() -> void:
	var camara := get_viewport().get_camera_2d()
	global_position = camara.get_screen_center_position() if camara else _jugador.global_position
	if process_mode == Node.PROCESS_MODE_ALWAYS:
		return
	for marca: MarcaSpawn in _spawner.marcas():
		marca.oculta = not esta_a_la_vista(marca.global_position)


func esta_a_la_vista(posicion: Vector2) -> bool:
	var d := posicion - global_position
	return Vector2(d.x, d.y / _jugador.params.anim_perspectiva).length() < radio + borde * 0.5
