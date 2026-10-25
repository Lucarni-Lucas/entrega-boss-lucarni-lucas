extends Node
class_name Spawner

signal enemigo_murio(posicion: Vector2, origen: Hitbox.Origen)
signal enemigo_aparecio(enemigo: Enemigo)
signal enemigo_se_fue(enemigo: Enemigo)
signal enemigo_golpeado(posicion: Vector2, origen: Hitbox.Origen)

@export var ronda_params: RondaParams
@export var params: SpawnerParams
@export var escena_marca: PackedScene
@export var contenedor: Node2D
@export var area := Rect2(0, 0, 2000, 1560)

var _guion: GuionRonda
var _proximos: Array[float] = []
var _tiempo_ronda := 0.0
var _pools: Dictionary[String, Pool] = {}
var _activos: Array[Enemigo] = []
var _pool_marcas: Pool
var _jugador: Player


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group(Player.GRUPO) as Player
	for numero in range(1, ronda_params.cantidad_rondas + 1):
		for grupo in ronda_params.guion(numero).grupos:
			_agregar_pool(grupo.enemigo)
	_pool_marcas = Pool.new(escena_marca, contenedor, _preparar_marca)
	_pool_marcas.precalentar.call_deferred(params.precalentar_marcas)
	set_physics_process(false)


func _agregar_pool(escena: PackedScene) -> void:
	if _pools.has(escena.resource_path):
		return
	var pool := Pool.new(escena, contenedor, _preparar_enemigo)
	pool.precalentar.call_deferred(params.precalentar)
	_pools[escena.resource_path] = pool


func _physics_process(delta: float) -> void:
	_tiempo_ronda += delta
	for i in _guion.grupos.size():
		var grupo := _guion.grupos[i]
		while _proximos[i] <= _tiempo_ronda and _proximos[i] <= grupo.hasta:
			_marcar_grupo(grupo)
			_proximos[i] += grupo.cada


func empezar_ronda(numero: int, _total: int) -> void:
	_guion = ronda_params.guion(numero)
	_proximos.clear()
	for grupo in _guion.grupos:
		_proximos.append(grupo.desde)
	_tiempo_ronda = 0.0
	set_physics_process(true)


func _marcar_grupo(grupo: GrupoSpawn) -> void:
	var centro := _buscar_posicion()
	if centro == Vector2.INF:
		return
	for i in grupo.cantidad:
		var punto := centro if i == 0 else _cerca_de(centro, grupo.radio)
		var marca: MarcaSpawn = _pool_marcas.tomar()
		marca.iniciar(punto, params, _jugador)
		marca.enemigo = grupo.enemigo


func _cerca_de(centro: Vector2, radio: float) -> Vector2:
	var zona := area.grow(-params.margen)
	var punto := centro + Vector2.from_angle(randf() * TAU) * sqrt(randf()) * radio
	return punto.clamp(zona.position, zona.end)


func _buscar_posicion() -> Vector2:
	for i in params.intentos:
		var punto := _punto_al_azar()
		if _jugador == null:
			return punto
		var distancia := punto.distance_to(_jugador.global_position)
		if distancia >= params.distancia_minima and distancia <= params.distancia_maxima:
			return punto
	return Vector2.INF


func _punto_al_azar() -> Vector2:
	var zona := area.grow(-params.margen)
	return zona.position + Vector2(randf() * zona.size.x, randf() * zona.size.y)


func _on_marca_lista(marca: MarcaSpawn) -> void:
	var posicion := marca.global_position
	var escena := marca.enemigo
	_pool_marcas.devolver(marca)
	var enemigo := _elegir_enemigo(escena)
	enemigo.activar_en(posicion)
	enemigo_aparecio.emit(enemigo)


func _preparar_enemigo(enemigo: Enemigo) -> void:
	enemigo.termino.connect(_devolver_enemigo)
	enemigo.murio.connect(enemigo_murio.emit)
	enemigo.golpeado.connect(enemigo_golpeado.emit)


func _preparar_marca(marca: MarcaSpawn) -> void:
	marca.lista.connect(_on_marca_lista)


func _elegir_enemigo(escena: PackedScene) -> Enemigo:
	if _activos.size() >= params.max_enemigos:
		var viejo := _mas_viejo_vivo()
		if viejo != null:
			_devolver_enemigo(viejo)
	var enemigo: Enemigo = _pools[escena.resource_path].tomar()
	_activos.append(enemigo)
	return enemigo


func _devolver_enemigo(enemigo: Enemigo) -> void:
	_activos.erase(enemigo)
	_pools[enemigo.scene_file_path].devolver(enemigo)
	enemigo_se_fue.emit(enemigo)


func _mas_viejo_vivo() -> Enemigo:
	for enemigo in _activos:
		if not enemigo.muerto:
			return enemigo
	return null


func terminar_ronda(_numero: int) -> void:
	set_physics_process(false)
	for enemigo in _activos.duplicate():
		_devolver_enemigo(enemigo)
	for marca in _pool_marcas.en_uso().duplicate():
		_pool_marcas.devolver(marca)
