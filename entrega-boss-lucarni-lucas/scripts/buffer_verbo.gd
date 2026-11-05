extends RefCounted
class_name BufferVerbo

var _accion: StringName
var _restante := 0.0


func _init(accion: StringName) -> void:
	_accion = accion


func actualizar(delta: float, ventana: float, vale := true) -> bool:
	_restante = maxf(_restante - delta, 0.0)
	if vale and Input.is_action_just_pressed(_accion):
		_restante = ventana
	return _restante > 0.0


func consumir() -> void:
	_restante = 0.0
