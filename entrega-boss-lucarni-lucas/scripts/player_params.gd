class_name PlayerParams
extends Resource

@export_group("Caminar")
@export_range(0, 1000, 10, "suffix:px/s") var velocidad: float = 250.0

@export_group("Salto")
@export_range(0, 1500, 10, "suffix:px/s") var fuerza_salto: float = 380.0
@export_range(0, 5000, 50, "suffix:px/s²") var gravedad: float = 1200.0

@export_group("Slash")
@export var slash_dano: int = 1

@export_group("Ground pound")
@export var gp_radio_explosion: float = 0.0   # Ground pound explosivo lo sube

@export_group("Dive")
@export var dive_cargas_max: int = 1          # Dive doble lo pone en 2

@export_group("Boomerang")
@export_range(0, 5, 0.1, "suffix:s") var boomerang_duracion: float = 1.2
