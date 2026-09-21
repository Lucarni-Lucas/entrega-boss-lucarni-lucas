extends Area2D
class_name Hurtbox

signal golpeado(hitbox: Hitbox)

@export var z_min := 0.0
@export var z_max := 20.0


func recibir_golpe(hitbox: Hitbox) -> void:
	golpeado.emit(hitbox)
