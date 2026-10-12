extends Node
class_name Spawner

signal enemigo_murio(posicion: Vector2, origen: Hitbox.Origen)

@export var ronda_params: RondaParams
@export var params: SpawnerParams
@export var escena_enemigo: PackedScene
@export var escena_marca: PackedScene
@export var contenedor: Node2D
@export var area := Rect2(0, 0, 2000, 1500)

var _guion: GuionRonda
var _proximos: Array[float] = []
var _tiempo_ronda := 0.0
var _pool_enemigos: Pool
var _pool_marcas: Pool
var _jugador: Player


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group(Player.GRUPO) as Player
	_pool_enemigos = Pool.new(escena_enemigo, contenedor, _preparar_enemigo)
	_pool_marcas = Pool.new(escena_marca, contenedor, _preparar_marca)
	_pool_enemigos.precalentar.call_deferred(params.precalentar)
	_pool_marcas.precalentar.call_deferred(params.precalentar_marcas)
	set_physics_process(false)


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
	_pool_marcas.devolver(marca)
	_elegir_enemigo().activar_en(posicion)


func _preparar_enemigo(enemigo: Enemigo) -> void:
	enemigo.termino.connect(_pool_enemigos.devolver)
	enemigo.murio.connect(enemigo_murio.emit)


func _preparar_marca(marca: MarcaSpawn) -> void:
	marca.lista.connect(_on_marca_lista)


func _elegir_enemigo() -> Enemigo:
	if _pool_enemigos.en_uso().size() >= params.max_enemigos:
		var viejo := _mas_viejo_vivo()
		if viejo != null:
			_pool_enemigos.devolver(viejo)
	return _pool_enemigos.tomar()


func _mas_viejo_vivo() -> Enemigo:
	for nodo in _pool_enemigos.en_uso():
		var enemigo := nodo as Enemigo
		if not enemigo.muerto:
			return enemigo
	return null


func terminar_ronda(_numero: int) -> void:
	set_physics_process(false)
	for enemigo in _pool_enemigos.en_uso().duplicate():
		_pool_enemigos.devolver(enemigo)
	for marca in _pool_marcas.en_uso().duplicate():
		_pool_marcas.devolver(marca)
