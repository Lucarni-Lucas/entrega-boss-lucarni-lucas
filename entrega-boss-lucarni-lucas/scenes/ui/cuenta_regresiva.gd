extends CanvasLayer

signal terminada

const _DELTA_MAXIMO := 1.0 / 30.0

@export var params: RondaParams

var _restante := 0.0
var _activa := false

@onready var _numero: Label = $Numero


func _ready() -> void:
	iniciar()


func iniciar() -> void:
	_restante = params.cuenta_desde * params.cuenta_paso
	_activa = true
	visible = true
	get_tree().paused = true
	_actualizar_numero()


func cancelar() -> void:
	_activa = false
	visible = false


func _process(delta: float) -> void:
	if not _activa:
		return
	_restante -= minf(delta, _DELTA_MAXIMO)
	if _restante > 0.0:
		_actualizar_numero()
		return
	_activa = false
	visible = false
	get_tree().paused = false
	terminada.emit()


func _actualizar_numero() -> void:
	_numero.text = str(ceili(_restante / params.cuenta_paso))
