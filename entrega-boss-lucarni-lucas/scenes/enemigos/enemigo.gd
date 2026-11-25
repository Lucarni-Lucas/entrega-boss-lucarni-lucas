extends CharacterBody2D
class_name Enemigo

signal murio(posicion: Vector2, origen: Hitbox.Origen)
signal termino(enemigo: Enemigo)
signal golpeado(posicion: Vector2, origen: Hitbox.Origen)

@export var params: EnemyParams

const PASOS_DESTELLO := 8

var z := 0.0
var vida: int
var jugador: Player
var muerto := false
var _empuje := Vector2.ZERO
var punto := Vector2.ZERO
var _capa: int
var _tween_muerte: Tween
var _tween_destello: Tween
var _factores := PackedFloat32Array()
var _fines := PackedFloat32Array()
var _tintes := PackedColorArray()
var _reloj_lento := 0.0
var _proximo_fin := INF
var _factor_lento := 1.0
var _agitacion := 0.0

@onready var _sombra: Sombra = $Sombra
@onready var _sprite := $Sprite
@onready var _hurtbox: Hurtbox = $Hurtbox
@onready var _visual: AnimatedSprite2D = $Sprite/Visual
@onready var _hitbox: Hitbox = $Hitbox
@onready var _posicion_visual: Vector2 = _visual.position


func _ready() -> void:
	_capa = collision_layer
	_visual.modulate = params.color
	z = params.altura_vuelo
	_hurtbox.z_min = z
	_hurtbox.z_max = z + params.alto
	_hurtbox.golpeado.connect(_on_golpeado)
	poner_dano_contacto(params.dano_contacto)
	_sprite.scale *= params.escala
	_hurtbox.scale *= params.escala
	_hitbox.scale *= params.escala
	_sombra.agrandar(params.escala)
	_hitbox.z_min = z
	_hitbox.z_max = z + params.alto
	_hitbox.continua = true
	_hitbox.intervalo = params.intervalo_contacto
	jugador = get_tree().get_first_node_in_group(Player.GRUPO) as Player
	activar_en(global_position)


func activar_en(posicion: Vector2) -> void:
	global_position = posicion
	vida = params.vida_max
	muerto = false
	_empuje = Vector2.ZERO
	punto = Vector2.ZERO
	modulate = Color.WHITE
	_quitar_lentitud()
	if _tween_destello:
		_tween_destello.kill()
	_poner_destello(0.0)
	agitar(0.0)
	_sprite.position.y = -z
	_sombra.actualizar(z)
	collision_layer = _capa
	_hurtbox.monitorable = true
	_hitbox.activar()
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	_visual.set_frame_and_progress(randi() % _visual.sprite_frames.get_frame_count(_visual.animation), randf())


func poner_dano_contacto(dano: int) -> void:
	_hitbox.dano = maxi(ceili(dano * params.factor_dano), 1) if dano > 0 else 0


func desactivar() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	_hitbox.desactivar()
	if _tween_muerte:
		_tween_muerte.kill()


func _physics_process(delta: float) -> void:
	_empuje = _empuje.move_toward(Vector2.ZERO, params.frenado_empuje * delta)
	if not _fines.is_empty():
		_pasar_lentitud(delta)
	if _agitacion > 0.0:
		_visual.position = _posicion_visual + Vector2(randf_range(-_agitacion, _agitacion), randf_range(-_agitacion, _agitacion))
	_mirar_al_jugador()
	_animar()


func agitar(amplitud: float) -> void:
	_agitacion = amplitud
	if amplitud <= 0.0:
		_visual.position = _posicion_visual


func recibir_dano(cantidad: int, origen := Hitbox.Origen.NINGUNO) -> void:
	vida -= cantidad
	if vida <= 0:
		morir(origen)


func morir(origen := Hitbox.Origen.NINGUNO) -> void:
	if muerto:
		return
	muerto = true
	murio.emit(global_position, origen)
	_hitbox.desactivar()
	_hurtbox.set_deferred("monitorable", false)
	set_deferred("collision_layer", 0)
	_tween_muerte = create_tween()
	_tween_muerte.tween_property(self, "modulate:a", 0.0, params.duracion_muerte)
	_tween_muerte.tween_callback(_terminar_muerte)


func _terminar_muerte() -> void:
	if termino.get_connections().is_empty():
		queue_free()
	else:
		termino.emit(self)


func _on_golpeado(hitbox: Hitbox) -> void:
	var direccion := _direccion_desde(hitbox.global_position)
	_empuje += direccion * hitbox.empuje * params.factor_empuje
	golpeado.emit(global_position + Vector2(0, -z - params.alto * 0.5) - direccion * 10.0, hitbox.origen)
	_destellar()
	recibir_dano(hitbox.dano, hitbox.origen)


func _destellar() -> void:
	if _tween_destello:
		_tween_destello.kill()
	_tween_destello = create_tween()
	_tween_destello.tween_method(_poner_destello, 1.0, 0.0, params.duracion_destello)


func _poner_destello(valor: float) -> void:
	var color := params.color
	color.r += 2.0 * ceili(valor * PASOS_DESTELLO)
	_visual.modulate = color


func empujar(desde: Vector2, fuerza: float) -> void:
	_empuje += _direccion_desde(desde) * fuerza * params.factor_empuje


func ralentizar(factor: float, segundos: float, tinte := Color.WHITE) -> void:
	var fin := _reloj_lento + segundos
	for i in _factores.size():
		if is_equal_approx(_factores[i], factor) and _tintes[i] == tinte:
			_fines[i] = maxf(_fines[i], fin)
			return
	_factores.append(factor)
	_fines.append(fin)
	_tintes.append(tinte)
	_proximo_fin = minf(_proximo_fin, fin)
	_aplicar_lentitud()


func esta_lento() -> bool:
	return not _fines.is_empty()


func _pasar_lentitud(delta: float) -> void:
	_reloj_lento += delta
	if _reloj_lento < _proximo_fin:
		return
	_proximo_fin = INF
	for i in range(_fines.size() - 1, -1, -1):
		if _fines[i] <= _reloj_lento:
			_factores.remove_at(i)
			_fines.remove_at(i)
			_tintes.remove_at(i)
		else:
			_proximo_fin = minf(_proximo_fin, _fines[i])
	_aplicar_lentitud()


func _aplicar_lentitud() -> void:
	_factor_lento = 1.0
	var tinte := Color.WHITE
	var factor_tinte := INF
	for i in _factores.size():
		_factor_lento = minf(_factor_lento, _factores[i])
		if _tintes[i] != Color.WHITE and _factores[i] < factor_tinte:
			tinte = _tintes[i]
			factor_tinte = _factores[i]
	_sprite.modulate = tinte


func _quitar_lentitud() -> void:
	_factores.clear()
	_fines.clear()
	_tintes.clear()
	_reloj_lento = 0.0
	_proximo_fin = INF
	_aplicar_lentitud()


func _direccion_desde(desde: Vector2) -> Vector2:
	var direccion := desde.direction_to(global_position)
	if direccion == Vector2.ZERO:
		direccion = Vector2.from_angle(randf() * TAU)
	return direccion


func velocidad_maxima() -> float:
	return params.velocidad * _factor_lento


func velocidad_externa() -> Vector2:
	return _empuje


func destino() -> Vector2:
	return jugador.global_position + punto


func _mirar_al_jugador() -> void:
	if jugador == null:
		return
	var dx := jugador.global_position.x - global_position.x
	if absf(dx) > 4.0:
		_visual.flip_h = dx < 0.0


## Solo los enemigos con animaciones "caminar" y "atacar" cambian según si se mueven.
func _animar() -> void:
	if muerto:
		return
	if not _visual.sprite_frames.has_animation(&"atacar"):
		_visual.speed_scale = _factor_lento
		return
	var rapidez := velocity.length()
	var animacion := &"caminar" if rapidez > params.velocidad * 0.2 else &"atacar"
	if _visual.animation != animacion:
		_visual.play(animacion)
	if animacion == &"caminar":
		var fps := _visual.sprite_frames.get_animation_speed(animacion)
		_visual.speed_scale = rapidez / (params.avance_por_frame * fps)
	else:
		_visual.speed_scale = _factor_lento
