extends CharacterBody2D
class_name Enemigo

signal murio(posicion: Vector2)

@export var params: EnemyParams

var z := 0.0
var vida: int

@onready var _sombra: Sombra = $Sombra
@onready var _sprite := $Sprite
@onready var _hurtbox: Hurtbox = $Hurtbox


func _ready() -> void:
	vida = params.vida_max
	z = params.altura_vuelo
	_hurtbox.z_min = z
	_hurtbox.z_max = z + params.alto
	_hurtbox.golpeado.connect(_on_golpeado)


func _physics_process(_delta: float) -> void:
	_sprite.position.y = -z
	_sombra.actualizar(z)


func recibir_dano(cantidad: int) -> void:
	vida -= cantidad
	if vida <= 0:
		morir()


func morir() -> void:
	murio.emit(global_position)
	queue_free()


func _on_golpeado(hitbox: Hitbox) -> void:
	modulate = Color.RED if modulate == Color.WHITE else Color.WHITE
	recibir_dano(hitbox.dano)
	await get_tree().create_timer(0.2).timeout
	modulate = Color.WHITE
