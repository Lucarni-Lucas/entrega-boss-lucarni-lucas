extends Enemigo


func _physics_process(delta: float) -> void:
	super(delta)
	if jugador == null:
		return
	var hacia := destino() - global_position
	var persecucion := Vector2.ZERO if muerto else (hacia / delta).limit_length(params.velocidad)
	velocity = persecucion + velocidad_externa()
	move_and_slide()
