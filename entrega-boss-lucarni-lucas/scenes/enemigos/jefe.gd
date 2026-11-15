extends Enemigo
class_name Jefe

signal pisoteado
signal exploto

const GRUPO := &"jefes"

enum Estado { PERSIGUE, AVISA, EMBISTE, ATURDIDO }

@export var escena_confeti: PackedScene
@export var pupila_alcance := Vector2(44.0, 10.0)
@export_range(0, 60, 0.5) var pupila_suavidad := 10.0
@export_range(0, 60, 0.5) var pupila_suavidad_aviso := 30.0
@export_range(0, 40, 0.5) var pupila_mareo := 14.0
@export_range(0, 200, 1, "suffix:px") var pupila_huida := 70.0
@export_range(0, 400, 1, "suffix:px") var altura_ojo := 109.0
@export_range(0, 1, 0.05) var muerte_inflado := 0.4
@export var muerte_estallidos := 6

var _estado := Estado.PERSIGUE
var _espera := 0.0
var _objetivo := Vector2.ZERO
var _direccion_embestida := Vector2.ZERO
var _tiempo_mareo := 0.0
var _avance_muerte := 0.0
var _pupila_al_morir := Vector2.ZERO
var _tween_aplastado: Tween

@onready var _pupila: Node2D = $Sprite/Visual/Ojo/Pupila
@onready var _barra: Node2D = $BarraVida


static func debajo_de(jugador: Player) -> Jefe:
	for nodo in jugador.get_tree().get_nodes_in_group(GRUPO):
		var jefe := nodo as Jefe
		if jefe and jefe.esta_debajo_de(jugador):
			return jefe
	return null


func _ready() -> void:
	add_to_group(GRUPO)
	super()


func activar_en(posicion: Vector2) -> void:
	super(posicion)
	_estado = Estado.PERSIGUE
	_espera = _p().embestida_cada
	_avance_muerte = 0.0
	if _tween_aplastado:
		_tween_aplastado.kill()
	_sprite.scale = Vector2.ONE
	_pupila.position = Vector2.ZERO
	_barra.reiniciar(ceili(float(params.vida_max) / maxi(_p().cabeza_dano, 1)))


func recibir_dano(cantidad: int, origen := Hitbox.Origen.NINGUNO) -> void:
	if muerto:
		return
	_barra.mostrar(maxi(vida - cantidad, 0), params.vida_max)
	super(cantidad, origen)


func _p() -> JefeParams:
	return params as JefeParams


func _physics_process(delta: float) -> void:
	super(delta)
	if jugador == null or muerto:
		velocity = Vector2.ZERO if muerto else velocidad_externa()
		move_and_slide()
		return
	_espera -= delta
	match _estado:
		Estado.PERSIGUE:
			var hacia := destino() - global_position
			velocity = (hacia / delta).limit_length(velocidad_maxima()) + velocidad_externa()
			if _espera <= 0.0:
				_avisar()
		Estado.AVISA:
			velocity = velocidad_externa()
			if _espera <= 0.0:
				_embestir()
		Estado.EMBISTE:
			velocity = _direccion_embestida * _p().embestida_velocidad * _factor_lento + velocidad_externa()
			if _espera <= 0.0:
				_perseguir()
		Estado.ATURDIDO:
			_tiempo_mareo += delta
			velocity = velocidad_externa()
			if _espera <= 0.0:
				_perseguir()
	move_and_slide()


func _avisar() -> void:
	_estado = Estado.AVISA
	_espera = _p().embestida_aviso
	_objetivo = jugador.global_position
	agitar(_p().embestida_temblor)


func _embestir() -> void:
	_estado = Estado.EMBISTE
	_espera = _p().embestida_duracion
	agitar(0.0)
	_direccion_embestida = global_position.direction_to(_objetivo)
	if _direccion_embestida == Vector2.ZERO:
		_direccion_embestida = Vector2.from_angle(randf() * TAU)


func _perseguir() -> void:
	_estado = Estado.PERSIGUE
	_espera = _p().embestida_cada


func _aturdir() -> void:
	_estado = Estado.ATURDIDO
	_espera = _p().aturdido
	_tiempo_mareo = 0.0
	agitar(0.0)
	if _tween_aplastado:
		_tween_aplastado.kill()
	_sprite.scale = _p().aturdido_aplastado
	_tween_aplastado = create_tween()
	_tween_aplastado.tween_property(_sprite, "scale", Vector2.ONE, _p().aturdido * 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)


func esta_embistiendo() -> bool:
	return _estado == Estado.EMBISTE


func esta_avisando() -> bool:
	return _estado == Estado.AVISA


func esta_aturdido() -> bool:
	return _estado == Estado.ATURDIDO and not muerto


func _mirar_al_jugador() -> void:
	if jugador == null or muerto:
		return
	if _estado == Estado.ATURDIDO:
		var angulo := _tiempo_mareo * pupila_mareo
		_pupila.position = Vector2(cos(angulo), sin(angulo)) * pupila_alcance * 0.8
		return
	var mirando := _objetivo if _estado != Estado.PERSIGUE else jugador.global_position + Vector2(0, -jugador.z)
	var direccion := (global_position + Vector2(0, -altura_ojo)).direction_to(mirando)
	var suavidad := pupila_suavidad if _estado == Estado.PERSIGUE else pupila_suavidad_aviso
	_pupila.position = _pupila.position.lerp(direccion * pupila_alcance, 1.0 - exp(-suavidad * get_physics_process_delta_time()))


func esta_debajo_de(otro: Player) -> bool:
	if muerto or not visible:
		return false
	var radio := _p().cabeza_radio
	var distancia := otro.global_position - global_position
	return pow(distancia.x / radio, 2) + pow(distancia.y / (radio * otro.params.anim_perspectiva), 2) <= 1.0


func altura_cabeza() -> float:
	return z + params.alto


func recibir_pisoton(otro: Player) -> void:
	var lado := global_position.direction_to(otro.global_position)
	if lado == Vector2.ZERO:
		lado = Vector2.from_angle(randf() * TAU)
	otro.rebotar_de_costado(_p().rebote_fuerza, lado * _p().rebote_empuje)
	pisoteado.emit()
	golpeado.emit(global_position + Vector2(0, -altura_cabeza()), Hitbox.Origen.GROUND_POUND)
	_destellar()
	_hitstop()
	_golpe_de_zoom()
	recibir_dano(_p().cabeza_dano, Hitbox.Origen.GROUND_POUND)
	if not muerto:
		_aturdir()


func _hitstop() -> void:
	if _p().hitstop <= 0.0:
		return
	Engine.time_scale = _p().hitstop_escala
	get_tree().create_timer(_p().hitstop, true, false, true).timeout.connect(Engine.set_time_scale.bind(1.0))


func _golpe_de_zoom() -> void:
	var camara := get_viewport().get_camera_2d()
	if camara and camara.has_method("golpe_de_zoom"):
		camara.golpe_de_zoom(_p().zoom_golpe, _p().zoom_duracion)


func _on_golpeado(hitbox: Hitbox) -> void:
	if hitbox.origen == Hitbox.Origen.GROUND_POUND:
		return
	super(hitbox)


func morir(origen := Hitbox.Origen.NINGUNO) -> void:
	if muerto:
		return
	muerto = true
	if _tween_aplastado:
		_tween_aplastado.kill()
	_sprite.scale = Vector2.ONE
	agitar(0.0)
	_pupila_al_morir = _pupila.position
	_barra.ocultar()
	_hitbox.desactivar()
	_hurtbox.set_deferred("monitorable", false)
	set_deferred("collision_layer", 0)
	murio.emit(global_position, origen)
	_tween_muerte = create_tween()
	_tween_muerte.tween_method(_agitarse, 0.0, 1.0, _p().muerte_agitacion)
	_tween_muerte.tween_callback(agitar.bind(0.0))
	_tween_muerte.tween_interval(_p().muerte_quieto)
	_tween_muerte.tween_callback(_explotar)


func _agitarse(avance: float) -> void:
	_avance_muerte = avance
	agitar(avance * avance * _p().muerte_temblor)
	_pupila.position = _pupila_al_morir.lerp(Vector2(0, -pupila_huida), avance)
	if randf() < avance * 0.12:
		_destellar()


func avance_muerte() -> float:
	return _avance_muerte


func _explotar() -> void:
	exploto.emit()
	if escena_confeti:
		var confeti: Node2D = escena_confeti.instantiate()
		confeti.position = global_position + Vector2(0, -params.alto * 0.5)
		get_parent().add_child(confeti)
	for i in muerte_estallidos:
		get_tree().create_timer(0.04 * i, false).timeout.connect(_estallar)
	_destellar()
	_tween_muerte = create_tween().set_parallel()
	_tween_muerte.tween_property(_sprite, "scale", Vector2.ONE * (1.0 + muerte_inflado), params.duracion_muerte)
	_tween_muerte.tween_property(self, "modulate:a", 0.0, params.duracion_muerte)
	_tween_muerte.chain().tween_callback(_terminar_muerte)


func _estallar() -> void:
	if not visible:
		return
	var desvio := Vector2(randf_range(-80.0, 80.0), randf_range(-params.alto * 0.9, -params.alto * 0.2))
	golpeado.emit(global_position + desvio, Hitbox.Origen.NINGUNO)
