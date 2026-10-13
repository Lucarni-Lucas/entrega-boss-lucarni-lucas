extends Enemigo

var _vuelo := Vector2.ZERO


func activar_en(posicion: Vector2) -> void:
	super(posicion)
	_vuelo = Vector2.ZERO


func _physics_process(delta: float) -> void:
	super(delta)
	if jugador == null:
		return
	var hacia := destino() - global_position
	var rapidez := minf(params.velocidad, sqrt(2.0 * params.aceleracion * hacia.length()))
	var persecucion := Vector2.ZERO if muerto else hacia.normalized() * rapidez
	_vuelo = _vuelo.move_toward(persecucion, params.aceleracion * delta)
	velocity = _vuelo + velocidad_externa()
	move_and_slide()
