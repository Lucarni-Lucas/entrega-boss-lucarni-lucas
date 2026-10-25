extends Resource
class_name CameraParams

@export_range(0, 500, 10, "suffix:px") var margen_vertical: float = 120.0
@export_range(0.5, 1, 0.05) var zoom_min: float = 0.75
@export_range(0.5, 10, 0.5) var velocidad_zoom: float = 3.0
@export_range(0, 1000, 10, "suffix:px") var banda_muerta: float = 250.0
@export_range(0, 1, 0.05) var seguimiento_vertical: float = 0.5
