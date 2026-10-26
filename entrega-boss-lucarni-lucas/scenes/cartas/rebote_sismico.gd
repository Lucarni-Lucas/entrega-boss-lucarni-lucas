extends EfectoCarta

@export var escena_onda: PackedScene
@export var tamano_pool := 4
@export_range(100, 10000, 50, "suffix:px/s") var velocidad_bajada := 1600.0
@export_range(0, 0.5, 0.01, "suffix:s") var bajada_minima := 0.06

var _ondas: Array[OndaSismica] = []


func _ready() -> void:
	for i in tamano_pool:
		var onda: OndaSismica = escena_onda.instantiate()
		add_child(onda)
		_ondas.append(onda)
	jugador.rebote_aereo.connect(_on_rebote_aereo)


func _on_rebote_aereo(posicion: Vector2, altura: float) -> void:
	var onda: OndaSismica = _ondas.pop_front()
	_ondas.push_back(onda)
	var duracion := maxf(altura / velocidad_bajada, bajada_minima)
	onda.bajar(posicion, altura, duracion, jugador.params.anim_perspectiva, _golpear.bind(posicion, jugador.fuerza_gp()))


func _golpear(posicion: Vector2, fuerza: float) -> void:
	jugador.impactar_gp(posicion, 0.0, fuerza)
