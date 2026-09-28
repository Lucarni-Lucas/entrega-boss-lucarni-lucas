extends CharacterBody2D
class_name Enemigo

signal murio(posicion: Vector2)

@export var params: EnemyParams

var z := 0.0
var vida: int
var jugador: Player

@onready var _sombra: Sombra = $Sombra
@onready var _sprite := $Sprite
@onready var _hurtbox: Hurtbox = $Hurtbox
@onready var _visual: Sprite2D = $Sprite/Visual
@onready var _hitbox: Hitbox = $Hitbox
@onready var _separacion: Area2D = $Separacion


func _ready() -> void:
	_visual.modulate = params.color
	vida = params.vida_max
	z = params.altura_vuelo
	_hurtbox.z_min = z
	_hurtbox.z_max = z + params.alto
	_hurtbox.golpeado.connect(_on_golpeado)
	jugador = get_tree().get_first_node_in_group("jugador") as Player
	_hitbox.dano = params.dano_contacto
	_hitbox.z_min = z
	_hitbox.z_max = z + params.alto
	_hitbox.continua = true
	_hitbox.activar()
	_hitbox.intervalo = params.intervalo_contacto


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
	recibir_dano(hitbox.dano)
	if vida <= 0:
		return
	modulate = Color.RED
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.2)


func empuje_separacion() -> Vector2:
	var empuje := Vector2.ZERO
	for otro in _separacion.get_overlapping_bodies():
		if otro != self:
			empuje += otro.global_position.direction_to(global_position)
	return empuje * params.fuerza_separacion
