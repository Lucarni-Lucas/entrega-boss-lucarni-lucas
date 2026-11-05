extends EfectoCarta

@export var escena_rayo: PackedScene
@export_range(0, 100, 1, "suffix:px") var elevacion_boomie := 22.0
@export_flags_2d_physics var mascara_enemigos := 4

var _espera := 0.0
var _rayo: Rayo
var _circulo := CircleShape2D.new()

@onready var _hitbox: Hitbox = $Hitbox


func _ready() -> void:
	_rayo = escena_rayo.instantiate()
	add_child(_rayo)
	jugador.rebote_aereo.connect(_on_rebote_aereo)
	jugador.volvio_al_inicio.connect(_rayo.desactivar)
	jugador.electrizar_boomie(true)


func esta_cargada() -> bool:
	return _espera <= 0.0


func _physics_process(delta: float) -> void:
	if esta_cargada():
		return
	_espera -= delta
	if esta_cargada():
		jugador.electrizar_boomie(true)
		Audio.tocar(Audio.libreria.rayo_listo)


func _on_rebote_aereo(posicion: Vector2, altura: float) -> void:
	if not esta_cargada():
		return
	var puntos := _encadenar(posicion)
	if puntos.size() < 2:
		return
	puntos[0] += Vector2(0, -altura - elevacion_boomie)
	_rayo.descargar(puntos)
	Audio.tocar(Audio.libreria.rayo)
	jugador.electrizar_boomie(false)
	_espera = jugador.params.boomerang_rayo_recarga


func _encadenar(desde: Vector2) -> PackedVector2Array:
	var params := jugador.params
	var puntos := PackedVector2Array([desde])
	var golpeados: Array[Enemigo] = []
	var actual := desde
	_hitbox.dano = jugador.dano_de(params.boomerang_rayo_dano)
	for i in params.boomerang_rayo_saltos:
		var hurtbox := _mas_cercano(actual, golpeados)
		if hurtbox == null:
			break
		var enemigo := hurtbox.get_parent() as Enemigo
		golpeados.append(enemigo)
		puntos.append(enemigo.global_position + Vector2(0, -enemigo.z - enemigo.params.alto * 0.5))
		_hitbox.global_position = actual
		hurtbox.recibir_golpe(_hitbox)
		actual = enemigo.global_position
	return puntos


func _mas_cercano(centro: Vector2, golpeados: Array[Enemigo]) -> Hurtbox:
	var params := jugador.params
	_circulo.radius = params.boomerang_rayo_alcance
	var consulta := PhysicsShapeQueryParameters2D.new()
	consulta.shape = _circulo
	consulta.transform = Transform2D(0.0, centro)
	consulta.collision_mask = mascara_enemigos
	consulta.collide_with_areas = true
	consulta.collide_with_bodies = false
	var mejor: Hurtbox = null
	var mejor_distancia := INF
	for resultado in jugador.get_world_2d().direct_space_state.intersect_shape(consulta, 128):
		var hurtbox := resultado.collider as Hurtbox
		if hurtbox == null:
			continue
		var enemigo := hurtbox.get_parent() as Enemigo
		if enemigo == null or enemigo.muerto or enemigo in golpeados:
			continue
		var d := enemigo.global_position - centro
		var distancia := Vector2(d.x, d.y / params.anim_perspectiva).length()
		if distancia <= params.boomerang_rayo_alcance and distancia < mejor_distancia:
			mejor = hurtbox
			mejor_distancia = distancia
	return mejor
