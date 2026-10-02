extends Node

signal tiempo_cambio(restante: float)
signal finalizo(gano: bool)

@export var params: RondaParams

var _restante: float
var _terminada := false


func _ready() -> void:
	_restante = params.duracion


func _physics_process(delta: float) -> void:
	_restante = maxf(_restante - delta, 0.0)
	tiempo_cambio.emit(_restante)
	if _restante == 0.0:
		_terminar(true)


func _on_player_murio() -> void:
	_terminar(false)


func _terminar(gano: bool) -> void:
	if _terminada:
		return
	_terminada = true
	finalizo.emit(gano)
	get_tree().paused = true
