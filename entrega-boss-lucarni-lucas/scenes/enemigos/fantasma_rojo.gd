extends "res://scenes/enemigos/volador.gd"

@export var escena_gota: PackedScene
@export var gotas_precalentadas := 4
@export_range(0.05, 10, 0.05, "suffix:s") var intervalo_gotas := 0.3
@export_range(0, 200, 1, "suffix:px") var radio_gotas := 30.0
@export_range(0, 10000, 50, "suffix:px/s²") var gravedad_gotas := 1800.0
@export_range(0, 2, 0.05) var factor_dano_gotas := 0.5

var _espera_gota := 0.0
var _pool_gotas: Pool


func _ready() -> void:
	super()
	_pool_gotas = Pool.new(escena_gota, get_parent(), _al_crear_gota)
	_pool_gotas.precalentar.call_deferred(gotas_precalentadas)


func activar_en(posicion: Vector2) -> void:
	super(posicion)
	_espera_gota = intervalo_gotas


func _al_crear_gota(gota: Proyectil) -> void:
	gota.termino.connect(_pool_gotas.devolver)


func _physics_process(delta: float) -> void:
	super(delta)
	if muerto or jugador == null:
		return
	_espera_gota -= delta
	if _espera_gota <= 0.0:
		_espera_gota += intervalo_gotas
		_soltar_gota()


func _soltar_gota() -> void:
	var angulo := randf() * TAU
	var distancia := radio_gotas * params.escala * sqrt(randf())
	var desvio := Vector2(cos(angulo), sin(angulo) * jugador.params.anim_perspectiva) * distancia
	var gota: Proyectil = _pool_gotas.tomar()
	var dano := maxi(ceili(_hitbox.dano * factor_dano_gotas), 1)
	gota.lanzar(global_position + desvio, z, Vector2.ZERO, 0.0, gravedad_gotas, sqrt(2.0 * z / gravedad_gotas) + 0.5, dano)
