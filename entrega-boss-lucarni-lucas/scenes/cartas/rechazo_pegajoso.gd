extends EfectoCarta

@export var tinte := Color("8fb0ea")
@export_flags_2d_physics var mascara_enemigos := 4

var _espera := 0.0
var _circulo := CircleShape2D.new()

@onready var _anillo: AnilloBaba = $Anillo


func _ready() -> void:
	jugador.golpe_de_enemigo.connect(_on_golpe_de_enemigo)
	jugador.volvio_al_inicio.connect(_reiniciar)


func esta_cargada() -> bool:
	return _espera <= 0.0


func _physics_process(delta: float) -> void:
	_espera = maxf(_espera - delta, 0.0)


func _on_golpe_de_enemigo() -> void:
	if not esta_cargada():
		return
	var params := jugador.params
	_espera = params.rechazo_recarga
	var centro := jugador.global_position
	for enemigo in _alcanzados(centro):
		enemigo.empujar(centro, params.rechazo_empuje)
		enemigo.ralentizar(params.rechazo_velocidad, params.rechazo_duracion, tinte)
	_anillo.expandir(centro, params.rechazo_radio, params.anim_perspectiva)
	Audio.tocar(Audio.libreria.rechazo)


func _reiniciar() -> void:
	_espera = 0.0
	_anillo.desactivar()


func _alcanzados(centro: Vector2) -> Array[Enemigo]:
	var params := jugador.params
	_circulo.radius = params.rechazo_radio
	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = _circulo
	consulta.transform = Transform2D(0.0, centro)
	consulta.collision_mask = mascara_enemigos
	consulta.collide_with_areas = true
	consulta.collide_with_bodies = false
	var alcanzados: Array[Enemigo] = []
	for resultado in jugador.get_world_2d().direct_space_state.intersect_shape(consulta, 256):
		var hurtbox := resultado.collider as Hurtbox
		if hurtbox == null:
			continue
		var enemigo := hurtbox.get_parent() as Enemigo
		if enemigo == null or enemigo.muerto or enemigo in alcanzados:
			continue
		var d := enemigo.global_position - centro
		if Vector2(d.x, d.y / params.anim_perspectiva).length() <= params.rechazo_radio:
			alcanzados.append(enemigo)
	return alcanzados
