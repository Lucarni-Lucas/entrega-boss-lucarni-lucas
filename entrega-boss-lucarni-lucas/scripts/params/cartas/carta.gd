extends Resource
class_name Carta

enum Verbo { SLASH, GROUND_POUND, DIVE, BOOMERANG, AIRE }

@export var nombre: String
@export var icono: Texture2D
@export_multiline var descripcion: String
@export var verbo: Verbo
@export var cambios: Dictionary[StringName, float] = {}
@export var efecto: PackedScene
