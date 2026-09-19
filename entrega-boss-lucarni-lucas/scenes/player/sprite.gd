extends Node2D

var _tween: Tween

@onready var _estiramiento := $Estiramiento
@onready var _visual := $Estiramiento/Visual

func deformar(escala: Vector2, duracion_ida: float, duracion_vuelta: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "scale", escala, duracion_ida)
	_tween.tween_property(self, "scale", Vector2.ONE, duracion_vuelta).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func estirar_segun_velocidad(velocidad: Vector2, params: PlayerParams) -> void:
	var factor := minf(1.0 + velocidad.length() * params.anim_estiramiento_factor, params.anim_estiramiento_max)
	_estiramiento.rotation = velocidad.angle()
	_estiramiento.scale = Vector2(factor, 1.0 / factor)
	_visual.rotation = -_estiramiento.rotation
