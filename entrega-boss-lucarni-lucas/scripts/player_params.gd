class_name PlayerParams
extends Resource

@export_group("Animación")
@export var anim_estiramiento_factor: float = 0.0004
@export_range(1, 2, 0.05) var anim_estiramiento_max: float = 1.15
@export var anim_aterrizaje_escala := Vector2(1.3, 0.75)
@export_range(0, 0.5, 0.01, "suffix:s") var anim_aterrizaje_ida: float = 0.06
@export_range(0, 0.5, 0.01, "suffix:s") var anim_aterrizaje_vuelta: float = 0.37

@export_group("Caminar")
@export_range(0, 1000, 10, "suffix:px/s") var velocidad: float = 420.0

@export_group("Salto")
@export_range(0, 3000, 10, "suffix:px/s") var fuerza_salto: float = 1300.0
@export_range(0, 10000, 50, "suffix:px/s²") var gravedad: float = 5000.0
@export_range(0, 0.3, 0.01, "suffix:s") var salto_buffer: float = 0.1

@export_group("Sombra")
@export_range(10, 1000, 10, "suffix:px") var sombra_altura_max: float = 600.0
@export_range(0, 1, 0.05) var sombra_escala_min: float = 0.65
@export_range(0, 1, 0.05) var sombra_alpha_max: float = 0.65
@export_range(0, 1, 0.05) var sombra_alpha_min: float = 0.4

@export_group("Slash")
@export var slash_dano: int = 1

@export_group("Ground pound")
@export var gp_radio_explosion: float = 0.0   

@export_group("Dive")
@export var dive_cargas_max: int = 1          

@export_group("Boomerang")
@export_range(0, 5, 0.1, "suffix:s") var boomerang_duracion: float = 1.2
