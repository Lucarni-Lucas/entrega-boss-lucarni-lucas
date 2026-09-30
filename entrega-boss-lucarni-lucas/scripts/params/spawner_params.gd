extends Resource
class_name SpawnerParams

@export_group("Ritmo")
@export_range(0.05, 10, 0.05, "suffix:s") var intervalo: float = 0.5
@export var curva_intervalo: Curve

@export_group("Cantidad")
@export var max_enemigos: int = 99
@export var precalentar: int = 20
@export var precalentar_marcas: int = 5

@export_group("Posición")
@export_range(0, 200, 5, "suffix:px") var margen: float = 40.0
@export_range(0, 1000, 10, "suffix:px") var distancia_minima: float = 400.0
@export var intentos: int = 10

@export_group("Marca")
@export var parpadeos: int = 3
@export var parpadeos_extra: int = 2
@export_range(0.05, 1, 0.01, "suffix:s") var duracion_parpadeo: float = 0.35
@export_range(0, 200, 5, "suffix:px") var radio_bloqueo: float = 60.0
