extends Enemigo


func _physics_process(delta: float) -> void:
	super(delta)
	if jugador == null:
		return
	var persecucion := Vector2.ZERO if muerto else global_position.direction_to(jugador.global_position) * params.velocidad
	velocity = persecucion + velocidad_externa()
	move_and_slide()
