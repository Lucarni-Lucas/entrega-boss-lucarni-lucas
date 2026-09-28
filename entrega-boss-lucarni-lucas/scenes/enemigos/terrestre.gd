extends Enemigo


func _physics_process(delta: float) -> void:
	super(delta)
	if jugador == null:
		return
	velocity = global_position.direction_to(jugador.global_position) * params.velocidad + empuje_separacion()
	move_and_slide()
