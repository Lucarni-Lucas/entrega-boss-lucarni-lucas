@tool
extends Resource
class_name GrupoSpawn

@export_range(1, 30, 1) var cantidad: int = 1
@export_range(0.1, 30, 0.1, "suffix:s") var cada: float = 1.5
@export_range(0, 300, 1, "suffix:s") var desde: float = 0.0
@export_range(0, 300, 1, "suffix:s") var hasta: float = 45.0
@export_range(0, 2000, 5, "suffix:px") var radio: float = 150.0
