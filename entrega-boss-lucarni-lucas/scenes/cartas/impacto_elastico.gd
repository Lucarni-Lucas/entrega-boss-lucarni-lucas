extends EfectoCarta

@export var escena_destello: PackedScene


func _ready() -> void:
	jugador.salto.connect(_on_salto)


func _on_salto() -> void:
	if not jugador.en_gracia_aerea():
		return
	jugador.recargar_energia_gp(jugador.params.gp_salto_recarga)
	var destello: Node2D = escena_destello.instantiate()
	destello.position = jugador.global_position
	jugador.get_parent().add_child(destello)
	Audio.tocar(Audio.libreria.impacto_elastico)
