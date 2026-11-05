extends Evento

@export var escena_marca: PackedScene
@export var escena_zona: PackedScene
@export_range(0, 30, 0.5, "suffix:s") var primera := 5.0
@export_range(0.5, 30, 0.5, "suffix:s") var cada := 4
@export var maximo := 16
@export_range(0, 2000, 10, "suffix:px") var separacion := 300.0
@export_range(0, 1000, 10, "suffix:px") var margen := 200.0
@export var intentos := 80
@export_range(0, 5, 0.1, "suffix:s") var transicion := 1.0

var _jugador: Player
var _spawner: Spawner
var _espera := 0.0
var _puntos: Array[Vector2] = []
var _zonas: Array[ZonaLava] = []
var _tiempo := 0.0


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group(Player.GRUPO) as Player
	_spawner = get_tree().get_first_node_in_group(Spawner.GRUPO) as Spawner
	_espera = primera


func _process(delta: float) -> void:
	_tiempo += delta
	ZonaLava.poner_tiempo(_tiempo)


func _physics_process(delta: float) -> void:
	if process_mode == Node.PROCESS_MODE_ALWAYS or _puntos.size() >= maximo:
		return
	_espera -= delta
	if _espera > 0.0:
		return
	_espera = cada
	var punto := _buscar_punto()
	if punto == Vector2.INF:
		return
	_puntos.append(punto)
	var marca: MarcaSpawn = escena_marca.instantiate()
	add_child(marca)
	marca.iniciar(punto, _spawner.params, _jugador)
	marca.lista.connect(_prender)


func terminar() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for hijo in get_children():
		if hijo is MarcaSpawn:
			hijo.queue_free()
	for zona in _zonas:
		zona.apagar(transicion)
	var tween := create_tween()
	tween.tween_interval(transicion)
	tween.tween_callback(queue_free)


func _prender(marca: MarcaSpawn) -> void:
	var zona: ZonaLava = escena_zona.instantiate()
	add_child(zona)
	zona.prender(marca.global_position, _jugador.params.anim_perspectiva)
	_zonas.append(zona)
	marca.queue_free()


func _buscar_punto() -> Vector2:
	var zona_valida := _spawner.area.grow(-margen)
	for i in intentos:
		var punto := Vector2(randf_range(zona_valida.position.x, zona_valida.end.x), randf_range(zona_valida.position.y, zona_valida.end.y))
		if _puntos.all(func(otro: Vector2) -> bool: return otro.distance_to(punto) >= separacion):
			return punto
	return Vector2.INF
