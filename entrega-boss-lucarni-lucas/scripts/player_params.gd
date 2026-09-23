extends Resource
class_name PlayerParams

@export_group("Animación")
#JUMP
@export var anim_estiramiento_factor: float = 0.0004
@export_range(1, 2, 0.05) var anim_estiramiento_max: float = 1.15
@export var anim_aterrizaje_escala := Vector2(1.3, 0.75)
@export_range(0, 0.5, 0.01, "suffix:s") var anim_aterrizaje_ida: float = 0.06
@export_range(0, 0.5, 0.01, "suffix:s") var anim_aterrizaje_vuelta: float = 0.37
#SLASH
@export_range(0.1, 1, 0.05) var anim_perspectiva: float = 0.45
#GP
@export var anim_gp_anticipo_escala := Vector2(1.25, 0.8)
@export_range(0, 0.5, 0.01, "suffix:s") var anim_gp_anticipo_vuelta: float = 0.05
@export var anim_gp_impacto_escala := Vector2(1.6, 0.55)
@export_range(0, 0.5, 0.01, "suffix:s") var anim_gp_impacto_ida: float = 0.05
@export_range(0, 1.2, 0.01, "suffix:s") var anim_gp_impacto_vuelta: float = 0.3
#BOOVAULT
@export var anim_rebote_escala := Vector2(0.7, 1.4)
@export_range(0, 0.5, 0.01, "suffix:s") var anim_rebote_ida: float = 0.05
@export_range(0, 0.5, 0.01, "suffix:s") var anim_rebote_vuelta: float = 0.2

@export_group("Caminar")
@export_range(0, 1000, 1, "suffix:px/s") var velocidad: float = 449.0

@export_group("Salto")
@export_range(0, 3000, 10, "suffix:px/s") var fuerza_salto: float = 1300.0
@export_range(0, 10000, 50, "suffix:px/s²") var gravedad: float = 5000.0
@export_range(0, 0.3, 0.01, "suffix:s") var salto_buffer: float = 0.1

@export_group("Sombra")
@export_range(10, 1000, 10, "suffix:px") var sombra_altura_max: float = 600.0
@export_range(0, 1, 0.05) var sombra_escala_min: float = 0.65
@export_range(0, 1, 0.05) var sombra_alpha_max: float = 0.65
@export_range(0, 1, 0.05) var sombra_alpha_min: float = 0.4

@export_group("Cuerpo")
@export_range(0, 200, 1, "suffix:px") var alto_cuerpo: float = 64.0

@export_group("Slash")
@export var slash_dano: int = 1
@export_range(0, 1, 0.01, "suffix:s") var slash_duracion: float = 0.15
@export_range(0, 2, 0.01, "suffix:s") var slash_cooldown: float = 0.3
@export_range(0, 200, 5, "suffix:px") var slash_alcance: float = 90.0
@export_range(0, 360, 5, "suffix:°") var slash_arco: float = 120.0
@export_range(0, 200, 5, "suffix:px") var slash_radio_efecto: float = 60.0
@export_range(0, 0.5, 0.01, "suffix:s") var slash_estela_desvanecer: float = 0.12

@export_group("Ground pound")
@export_range(0, 300, 5, "suffix:px") var gp_altura_minima: float = 80.0
@export_range(0, 0.5, 0.01, "suffix:s") var gp_anticipacion: float = 0.22
@export_range(0, 5000, 50, "suffix:px/s") var gp_velocidad: float = 2000.0
@export var gp_dano: int = 1
@export_range(0, 300, 5, "suffix:px") var gp_radio_impacto: float = 50.0
@export var gp_radio_explosion: float = 0.0
@export_range(0.03, 0.3, 0.01, "suffix:s") var gp_impacto_duracion: float = 0.07

@export_group("Dive")
@export_range(0, 3000, 5, "suffix:px/s") var dive_velocidad: float = 950.0
@export_range(0, 2000, 5, "suffix:px/s") var dive_impulso_vertical: float = 550.0
@export_range(0, 1, 0.05) var dive_escala_gravedad: float = 1.0
@export var dive_cargas_max: int = 1

@export_group("Boomerang")
@export_range(0, 3000, 10, "suffix:px/s") var boomerang_velocidad: float = 1200.0
@export_range(0, 1000, 10, "suffix:px") var boomerang_distancia: float = 190.0
@export_range(0, 5, 0.1, "suffix:s") var boomerang_duracion: float = 1.2
@export_range(0, 3000, 10, "suffix:px/s") var boomerang_velocidad_vuelta: float = 1400.0
@export_range(0, 1, 0.01, "suffix:s") var throw_duracion: float = 0.23
@export_range(0, 1, 0.05) var throw_factor_velocidad: float = 0.2
@export_range(0, 1, 0.05) var throw_escala_gravedad: float = 0.0
@export_range(0, 200, 5, "suffix:px") var boomerang_alto: float = 24.0
@export var boomerang_rebotes_max: int = 1

@export_group("Rebote")
@export_range(0, 4000, 10, "suffix:px/s") var vault_fuerza: float = 1300.0
