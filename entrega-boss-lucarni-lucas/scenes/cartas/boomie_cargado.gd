extends EfectoCarta

@export var escena_destello: PackedScene
@export var tamano_pool := 2
@export_range(0, 100, 1, "suffix:px") var elevacion := 22.0

var _destellos: Array[DestelloBoomie] = []


func _ready() -> void:
	for i in tamano_pool:
		var destello: DestelloBoomie = escena_destello.instantiate()
		add_child(destello)
		_destellos.append(destello)
	jugador.cargo_boomie.connect(_on_cargo_boomie)
	jugador.estallo_boomie.connect(_on_estallo_boomie)
	jugador.volvio_al_inicio.connect(_cortar_destellos)


func _on_cargo_boomie() -> void:
	Audio.tocar(Audio.libreria.boomie_absorbe)


func _on_estallo_boomie(posicion: Vector2, altura: float) -> void:
	var destello: DestelloBoomie = _destellos.pop_front()
	_destellos.push_back(destello)
	destello.explotar(posicion + Vector2(0, -altura - elevacion))


func _cortar_destellos() -> void:
	for destello in _destellos:
		destello.desactivar()
