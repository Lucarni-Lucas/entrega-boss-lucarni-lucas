extends Sprite2D
class_name Sombra

@export var params: SombraParams

@onready var _escala_base := scale


func actualizar(z: float) -> void:
	var altura_relativa := clampf(z / params.altura_max, 0.0, 1.0)
	scale = _escala_base * lerpf(1.0, params.escala_min, altura_relativa)
	modulate.a = lerpf(params.alpha_max, params.alpha_min, altura_relativa)
