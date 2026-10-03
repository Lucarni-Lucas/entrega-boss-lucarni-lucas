extends Resource
class_name RondaParams

@export_range(10, 300, 5, "suffix:s") var duracion: float = 90.0

@export_group("Cuenta regresiva")
@export var cuenta_desde: int = 3
@export_range(0.1, 2, 0.05, "suffix:s") var cuenta_paso: float = 0.5

@export_group("Pantalla final")
@export_range(0, 3, 0.1, "suffix:s") var bloqueo_final: float = 1.0
