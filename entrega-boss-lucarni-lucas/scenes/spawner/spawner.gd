extends Node
class_name Spawner

signal enemigo_murio(posicion: Vector2, origen: Hitbox.Origen)

@export var params: SpawnerParams
@export var escena_enemigo: PackedScene
@export var escena_marca: PackedScene
@export var contenedor: Node2D
@export var area := Rect2(0, 0, 2000, 1500)

const _INTERVALO_MINIMO := 0.05

var _tiempo_partida := 0.0
var _pool_enemigos: Pool
var _pool_marcas: Pool
var _jugador: Player
var _tiempo := 0.0


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group(Player.GRUPO) as Player
	_pool_enemigos = Pool.new(escena_enemigo, contenedor, _preparar_enemigo)
	_pool_marcas = Pool.new(escena_marca, contenedor, _preparar_marca)
	_pool_enemigos.precalentar.call_deferred(params.precalentar)
	_pool_marcas.precalentar.call_deferred(params.precalentar_marcas)


func _physics_process(delta: float) -> void:
	_tiempo_partida += delta
	_tiempo += delta
	var intervalo := _intervalo_actual()
	while _tiempo >= intervalo:
		_tiempo -= intervalo
		_marcar_spawn()


func _marcar_spawn() -> void:
	var posicion := _buscar_posicion()
	if posicion == Vector2.INF:
		return
	var marca: MarcaSpawn = _pool_marcas.tomar()
	marca.iniciar(posicion, params, _jugador)


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


func _intervalo_actual() -> float:
	if params.curva_intervalo == null:
		return params.intervalo
	return maxf(params.curva_intervalo.sample(_tiempo_partida), _INTERVALO_MINIMO)
