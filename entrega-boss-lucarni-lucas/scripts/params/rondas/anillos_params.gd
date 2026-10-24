extends Resource
class_name AnillosParams

@export_group("Anillos")
@export_range(1, 6, 1) var cantidad: int = 3
@export_range(5, 100, 1, "suffix:px") var separacion: float = 25.0
@export_range(5, 100, 1, "suffix:px") var ancho_enemigo: float = 25.0
@export_range(0.1, 1, 0.05) var perspectiva: float = 0.65

@export_group("Horda")
@export_range(0, 100, 1, "suffix:px") var franja_espera: float = 25.0

@export_group("Reparto")
@export_range(0.05, 2, 0.05, "suffix:s") var intervalo: float = 0.3
@export_range(0, 200, 5, "suffix:px") var margen: float = 20.0
