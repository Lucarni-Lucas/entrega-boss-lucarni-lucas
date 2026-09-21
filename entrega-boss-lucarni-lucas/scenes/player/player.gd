extends CharacterBody2D
class_name Player

signal aterrizo

@export var params: PlayerParams

var ultima_direccion := Vector2.DOWN
var z := 0.0
## Positiva sube, negativa baja.
var velocidad_z := 0.0
var tiene_boomerang := true

@onready var _walk := $Walk
@onready var _sprite := $Sprite
@onready var _shadow := $Shadow
@onready var _jump := $Jump
@onready var _slash := $Slash


func _ready() -> void:
	aterrizo.connect(_on_aterrizo)


func _physics_process(delta: float) -> void:
	_walk.procesar_fisica(self, delta)
	_jump.procesar_fisica(self, delta)
	move_and_slide()

	_actualizar_altura(delta)
	_sprite.position.y = -z
	_slash.procesar_fisica(self, delta)
	_shadow.actualizar(z, params)
	_sprite.estirar_segun_velocidad(_velocidad_en_pantalla(), params)


## Altura del suelo debajo del jugador.
func suelo_actual() -> float:
	return 0.0


func esta_en_suelo() -> bool:
	return z <= suelo_actual() + 0.01


func aplicar_impulso_vertical(fuerza: float) -> void:
	velocidad_z = fuerza


func _velocidad_en_pantalla() -> Vector2:
	if esta_en_suelo():
		return Vector2.ZERO
	return Vector2(velocity.x, velocity.y - velocidad_z)


func _actualizar_altura(delta: float) -> void:
	if esta_en_suelo() and velocidad_z <= 0.0:
		return
	velocidad_z -= params.gravedad * delta
	z += velocidad_z * delta
	if z <= suelo_actual():
		z = suelo_actual()
		velocidad_z = 0.0
		aterrizo.emit()


func _on_aterrizo() -> void:
	_sprite.deformar(params.anim_aterrizaje_escala, params.anim_aterrizaje_ida, params.anim_aterrizaje_vuelta)
