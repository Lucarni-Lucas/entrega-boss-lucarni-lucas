extends EfectoCarta

@export var escena_gota: PackedScene
@export var gotas_precalentadas := 20

var _pool: Pool
var _esperas := {}


func _ready() -> void:
	_pool = Pool.new(escena_gota, jugador.get_parent(), _al_crear_gota)
	_pool.precalentar.call_deferred(gotas_precalentadas)
	jugador.volvio_al_inicio.connect(_on_volvio_al_inicio)


func _al_crear_gota(gota: Proyectil) -> void:
	gota.termino.connect(_pool.devolver)


func _on_volvio_al_inicio() -> void:
	_pool.devolver_todos()
	_esperas.clear()


func _physics_process(delta: float) -> void:
	var params := jugador.params
	for boomie: Boomerang in get_tree().get_nodes_in_group(Boomerang.GRUPO):
		if not boomie.esta_flotando() or boomie.z < params.boomerang_llovizna_altura_min:
			_esperas.erase(boomie)
			continue
		var espera: float = _esperas.get(boomie, 0.0) - delta
		if espera <= 0.0:
			_soltar_gota(boomie, params)
			espera += params.boomerang_llovizna_intervalo
		_esperas[boomie] = espera


func _soltar_gota(boomie: Boomerang, params: PlayerParams) -> void:
	var gravedad := params.boomerang_llovizna_gravedad
	var caida := sqrt(2.0 * boomie.z / gravedad)
	var angulo := randf() * TAU
	var distancia := params.boomerang_radio_dano * sqrt(randf())
	var desvio := Vector2(cos(angulo), sin(angulo) * params.anim_perspectiva) * distancia
	var gota: Proyectil = _pool.tomar()
	gota.lanzar(boomie.global_position + desvio, boomie.z, Vector2.ZERO, 0.0, gravedad, caida + 0.5, jugador.dano_de(params.boomerang_llovizna_dano))
