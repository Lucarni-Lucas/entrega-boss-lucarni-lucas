extends Node

signal ronda_empezo(numero: int, total: int)
signal ronda_termino(numero: int)
signal tiempo_cambio(restante: float)
signal finalizo(gano: bool)
signal ronda_superada(numero: int, total: int)

enum Estado { RONDA, ENTRE_RONDAS, VICTORIA, DERROTA }

@export var params: RondaParams

var _estado := Estado.ENTRE_RONDAS
var _ronda := 0
var _restante := 0.0


func _ready() -> void:
	_empezar_ronda.call_deferred()


func _physics_process(delta: float) -> void:
	if _estado != Estado.RONDA:
		return
	_restante = maxf(_restante - delta, 0.0)
	tiempo_cambio.emit(_restante)
	if _restante == 0.0:
		_terminar_ronda()


func _on_player_murio() -> void:
	_terminar(Estado.DERROTA)


func _empezar_ronda() -> void:
	_ronda += 1
	_estado = Estado.RONDA
	_restante = params.duracion
	tiempo_cambio.emit(_restante)
	ronda_empezo.emit(_ronda, params.cantidad_rondas)


func _terminar_ronda() -> void:
	ronda_termino.emit(_ronda)
	if _ronda == params.cantidad_rondas:
		_terminar(Estado.VICTORIA)
	else:
		_estado = Estado.ENTRE_RONDAS
		get_tree().paused = true
		ronda_superada.emit(_ronda, params.cantidad_rondas)


func _terminar(estado: Estado) -> void:
	if _estado == Estado.VICTORIA or _estado == Estado.DERROTA:
		return
	_estado = estado
	finalizo.emit(estado == Estado.VICTORIA)
	get_tree().paused = true


func siguiente_ronda() -> void:
	if _estado == Estado.ENTRE_RONDAS:
		_empezar_ronda()
