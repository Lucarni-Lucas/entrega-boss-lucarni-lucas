extends RefCounted
class_name Formas


static func elipse(radio: float, perspectiva: float, segmentos: int = 16) -> PackedVector2Array:
	var puntos := PackedVector2Array()
	for i in segmentos:
		var angulo := TAU * i / segmentos
		puntos.append(Vector2(cos(angulo), sin(angulo) * perspectiva) * radio)
	return puntos
