extends Node
class_name Spawner

@export var params: SpawnerParams
@export var escena_enemigo: PackedScene
@export var escena_marca: PackedScene
@export var contenedor: Node2D
@export var area := Rect2(0, 0, 2000, 1500)

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
	_tiempo += delta
	if _tiempo >= params.intervalo:
		_tiempo -= params.intervalo
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
		if _jugador == null or punto.distance_to(_jugador.global_position) >= params.distancia_minima:
			return punto
	return Vector2.INF


func _punto_al_azar() -> Vector2:
	var zona := area.grow(-params.margen)
	return zona.position + Vector2(randf() * zona.size.x, randf() * zona.size.y)


func _on_marca_lista(marca: MarcaSpawn) -> void:
	var posicion := marca.global_position
	_pool_marcas.devolver(marca)
	var enemigo: Enemigo = _pool_enemigos.tomar()
	enemigo.activar_en(posicion)


func _preparar_enemigo(enemigo: Enemigo) -> void:
	enemigo.termino.connect(_pool_enemigos.devolver)


func _preparar_marca(marca: MarcaSpawn) -> void:
	marca.lista.connect(_on_marca_lista)
