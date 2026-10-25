extends CanvasLayer

signal terminada
signal numero_cambio(valor: int)

const _DELTA_MAXIMO := 1.0 / 30.0

@export var params: RondaParams

var _restante := 0.0
var _activa := false
var _numero_mostrado := 0

@onready var _numero: Label = $Numero


func iniciar() -> void:
	_restante = params.cuenta_desde * params.cuenta_paso
	_activa = true
	visible = true
	get_tree().paused = true
	_numero_mostrado = 0
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
	var valor := ceili(_restante / params.cuenta_paso)
	if valor == _numero_mostrado:
		return
	_numero_mostrado = valor
	_numero.text = str(valor)
	numero_cambio.emit(valor)
