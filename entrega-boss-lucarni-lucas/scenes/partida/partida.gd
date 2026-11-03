extends Node

signal ronda_empezo(numero: int, total: int)
signal ronda_termino(numero: int)
signal tiempo_cambio(restante: float)
signal finalizo(gano: bool)
signal ronda_superada(numero: int, total: int)

enum Estado { RONDA, ENTRE_RONDAS, VICTORIA, DERROTA }

@export var params: RondaParams
@export_group("Pruebas")
@export_range(0, 20, 1) var ronda_de_prueba := 0
@export_range(0, 300, 1, "suffix:s") var duracion_de_prueba := 0.0

var _estado := Estado.ENTRE_RONDAS
var _ronda := 0
var _restante := 0.0
var _evento: Node


func _ready() -> void:
	if OS.has_feature("editor") and ronda_de_prueba > 0:
		_ronda = mini(ronda_de_prueba, params.cantidad_rondas) - 1
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
	var guion := params.guion(_ronda)
	_restante = guion.duracion
	if OS.has_feature("editor") and duracion_de_prueba > 0.0:
		_restante = duracion_de_prueba
	if guion.evento:
		_evento = guion.evento.instantiate()
		add_child(_evento)
	tiempo_cambio.emit(_restante)
	ronda_empezo.emit(_ronda, params.cantidad_rondas)


func _terminar_ronda() -> void:
	_sacar_evento()
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
	_sacar_evento()
	finalizo.emit(estado == Estado.VICTORIA)
	get_tree().paused = true


func _sacar_evento() -> void:
	if _evento:
		_evento.queue_free()
		_evento = null


func siguiente_ronda() -> void:
	if _estado == Estado.ENTRE_RONDAS:
		_empezar_ronda()
