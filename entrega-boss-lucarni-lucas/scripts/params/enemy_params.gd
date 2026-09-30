extends Resource
class_name EnemyParams

@export_group("Cuerpo")
@export var vida_max: int = 2
@export_range(0, 500, 5, "suffix:px") var alto: float = 40.0
@export_range(0, 500, 5, "suffix:px") var altura_vuelo: float = 0.0
@export var color := Color.WHITE

@export_group("Movimiento")
@export_range(0, 1000, 5, "suffix:px/s") var velocidad: float = 250.0
@export_range(0, 10000, 50, "suffix:px/s²") var frenado_empuje: float = 2400.0

@export_group("Contacto")
@export var dano_contacto: int = 5
@export_range(0.05, 2, 0.05, "suffix:s") var intervalo_contacto: float = 0.4

@export_group("Muerte")
@export_range(0, 2, 0.05, "suffix:s") var duracion_muerte: float = 0.5
