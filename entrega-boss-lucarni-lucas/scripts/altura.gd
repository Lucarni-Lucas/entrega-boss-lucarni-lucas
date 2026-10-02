extends RefCounted
class_name Altura


static func rangos_se_tocan(a_min: float, a_max: float, b_min: float, b_max: float) -> bool:
	return a_min < b_max and b_min < a_max
