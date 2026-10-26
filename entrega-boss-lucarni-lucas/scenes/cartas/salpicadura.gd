extends EfectoCarta

@export var escena_bolita: PackedScene
@export var bolitas_precalentadas := 16

var _pool: Pool


func _ready() -> void:
	_pool = Pool.new(escena_bolita, jugador.get_parent(), _al_crear_bolita)
	_pool.precalentar.call_deferred(bolitas_precalentadas)
	jugador.rebote_aereo.connect(_on_rebote_aereo)


func _al_crear_bolita(bolita: Proyectil) -> void:
	bolita.termino.connect(_pool.devolver)


func _on_rebote_aereo(posicion: Vector2, altura: float) -> void:
	var params := jugador.params
	var cantidad := params.boomerang_salpicadura_bolitas
	var duracion := params.boomerang_salpicadura_alcance / params.boomerang_salpicadura_velocidad
	Audio.tocar_una_vez_por_cuadro(Audio.libreria.salpicadura)
	for i in cantidad:
		var angulo := TAU * i / cantidad
		var direccion := Vector2(cos(angulo), sin(angulo) * params.anim_perspectiva)
		var bolita: Proyectil = _pool.tomar()
		bolita.lanzar(posicion, altura + params.boomerang_salpicadura_altura, direccion * params.boomerang_salpicadura_velocidad, 0.0, 0.0, duracion, jugador.dano_de(params.boomerang_salpicadura_dano))
