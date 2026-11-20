extends EnemyParams
class_name JefeParams

@export_group("Embestida")
@export_range(0, 30, 0.5, "suffix:s") var embestida_cada: float = 6.0
@export_range(0, 3, 0.05, "suffix:s") var embestida_aviso: float = 0.5
@export_range(0, 3000, 10, "suffix:px/s") var embestida_velocidad: float = 900.0
@export_range(0, 3, 0.05, "suffix:s") var embestida_duracion: float = 0.45
@export_range(0, 20, 0.5, "suffix:px") var embestida_temblor: float = 4.0

@export_group("Cabeza")
@export var cabeza_dano: int = 15
@export_range(0, 300, 5, "suffix:px") var cabeza_radio: float = 90.0
@export_range(0, 4000, 5, "suffix:px/s") var rebote_fuerza: float = 975.0
@export_range(0, 3000, 10, "suffix:px/s") var rebote_empuje: float = 700.0

@export_group("Pisotón")
@export_range(0, 5, 0.05, "suffix:s") var aturdido: float = 1.2
@export var aturdido_aplastado := Vector2(1.25, 0.75)
@export_range(0, 0.5, 0.01, "suffix:s") var hitstop: float = 0.1
@export_range(0, 1, 0.01) var hitstop_escala: float = 0.05
@export_range(1, 1.5, 0.01) var zoom_golpe: float = 1.08
@export_range(0, 2, 0.05, "suffix:s") var zoom_duracion: float = 0.4

@export_group("Muerte")
@export_range(0, 10, 0.1, "suffix:s") var muerte_agitacion: float = 2.0
@export_range(0, 40, 0.5, "suffix:px") var muerte_temblor: float = 14.0
@export_range(0, 2, 0.05, "suffix:s") var muerte_quieto: float = 0.35
