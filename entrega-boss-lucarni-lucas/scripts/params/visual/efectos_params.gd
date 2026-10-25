extends Resource
class_name EfectosParams

@export_group("Golpe")
@export var estrella_escala_inicial: float = 0.22
@export var estrella_escala_final: float = 0.4
@export_range(0, 1, 0.01, "suffix:s") var estrella_crecer: float = 0.06
@export_range(0, 1, 0.01, "suffix:s") var estrella_desvanecer: float = 0.14
@export var chispas_cantidad: int = 4
@export_range(0, 200, 1, "suffix:px") var chispas_distancia: float = 34.0
@export var chispas_escala: float = 0.25
@export_range(0, 1, 0.01, "suffix:s") var chispas_duracion: float = 0.25

@export_group("Ground pound")
@export_range(0, 1, 0.05) var anillo_radio_inicial: float = 0.55
@export_range(0, 1, 0.01, "suffix:s") var anillo_expansion: float = 0.12
@export_range(0, 1, 0.01, "suffix:s") var anillo_desvanecer: float = 0.25
@export_range(0, 20, 0.5, "suffix:px") var anillo_ancho_borde: float = 8.0
@export_range(0, 20, 0.5, "suffix:px") var anillo_ancho_interior: float = 4.0
@export var anillo_color_borde := Color("202024")
@export var anillo_color_interior := Color("f5f2e3")
