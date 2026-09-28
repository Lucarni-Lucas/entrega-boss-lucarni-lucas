extends Node2D
class_name MarcaSpawn

signal lista(marca: MarcaSpawn)

var _params: SpawnerParams
var _jugador: Player
var _parpadeos_restantes := 0
var _tiempo := 0.0

@onready var _visual := $Visual


func iniciar(posicion: Vector2, params: SpawnerParams, jugador: Player) -> void:
	global_position = posicion
	_params = params
	_jugador = jugador
	_parpadeos_restantes = params.parpadeos
	_tiempo = 0.0
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT


func desactivar() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED


func _physics_process(delta: float) -> void:
	_tiempo += delta
	_visual.visible = _tiempo < _params.duracion_parpadeo / 2.0
	if _tiempo < _params.duracion_parpadeo:
		return
	_tiempo -= _params.duracion_parpadeo
	_parpadeos_restantes -= 1
	if _parpadeos_restantes > 0:
		return
	if _jugador_encima():
		_parpadeos_restantes = _params.parpadeos_extra
		return
	lista.emit(self)


func _jugador_encima() -> bool:
	return _jugador != null and global_position.distance_to(_jugador.global_position) < _params.radio_bloqueo
