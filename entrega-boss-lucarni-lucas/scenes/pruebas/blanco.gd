extends Node2D

@onready var _hurtbox: Hurtbox = $Hurtbox


func _ready() -> void:
	_hurtbox.golpeado.connect(_on_golpeado)


func _on_golpeado(hitbox: Hitbox) -> void:
	print("%s recibió %d de daño" % [name, hitbox.dano])
	modulate = Color.RED if modulate == Color.WHITE else Color.WHITE
	await get_tree().create_timer(0.15).timeout
	modulate = Color.WHITE
