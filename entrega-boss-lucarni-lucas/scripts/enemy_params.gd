extends Resource
class_name EnemyParams

@export var vida_max: int = 3
@export_range(0, 1000, 5, "suffix:px/s") var velocidad: float = 150.0
@export_range(0, 500, 5, "suffix:px") var alto: float = 40.0
@export_range(0, 500, 5, "suffix:px") var altura_vuelo: float = 0.0
@export var dano_contacto: int = 5
