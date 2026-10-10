extends Resource
class_name TutorialParams

@export_group("Cadena")
@export var cadenas_necesarias: int = 2

@export_group("Tiempos")
@export_range(0.1, 2, 0.05, "suffix:s") var duracion_bien: float = 0.8
@export_range(0.1, 3, 0.05, "suffix:s") var duracion_final: float = 1.2
@export_range(0.5, 5, 0.1, "suffix:s") var duracion_aviso: float = 2.0

@export_group("Consejos")
@export_range(0, 3, 0.1, "suffix:s") var bloqueo_consejos: float = 1.0
