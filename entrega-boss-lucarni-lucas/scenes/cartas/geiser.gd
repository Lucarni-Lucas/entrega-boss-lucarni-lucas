extends EfectoCarta

@export var escena_gota: PackedScene
@export var gotas_precalentadas := 24
@export_range(0, 1, 0.05) var distancia_minima := 0.3

var _pool: Pool


func _ready() -> void:
	_pool = Pool.new(escena_gota, jugador.get_parent(), _al_crear_gota)
	_pool.precalentar.call_deferred(gotas_precalentadas)
	jugador.impacto_gp.connect(_on_impacto_gp)


func _al_crear_gota(gota: Proyectil) -> void:
	gota.termino.connect(_pool.devolver)


func _on_impacto_gp(posicion: Vector2, altura: float, radio: float, fuerza: float, _primario: bool) -> void:
	var params := jugador.params
	var gravedad := params.gp_geiser_gravedad
	var cantidad := roundi(lerpf(1.0, params.gp_geiser_gotas, fuerza))
	var cima := params.gp_geiser_altura * lerpf(params.gp_geiser_altura_min, 1.0, fuerza)
	var subida := sqrt(2.0 * gravedad * maxf(cima - altura, 0.0))
	var vuelo := (subida + sqrt(subida * subida + 2.0 * gravedad * altura)) / gravedad
	Audio.tocar_una_vez_por_cuadro(Audio.libreria.geiser)
	for i in cantidad:
		var angulo := TAU * (i + randf()) / cantidad
		var distancia := radio * params.gp_geiser_zona * randf_range(distancia_minima, 1.0)
		var destino := Vector2(cos(angulo), sin(angulo) * params.anim_perspectiva) * distancia
		var gota: Proyectil = _pool.tomar()
		gota.lanzar(posicion, altura, destino / vuelo, subida, gravedad, vuelo + 0.5, jugador.dano_de(params.gp_geiser_dano))
