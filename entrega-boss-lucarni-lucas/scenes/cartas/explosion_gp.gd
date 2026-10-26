extends EfectoCarta

@export var escena_estallido: PackedScene
@export var tamano_pool := 8

var _estallidos: Array[Estallido] = []


func _ready() -> void:
	for i in tamano_pool:
		var estallido: Estallido = escena_estallido.instantiate()
		add_child(estallido)
		_estallidos.append(estallido)
	jugador.impacto_gp.connect(_explotar)


func _explotar(posicion: Vector2, altura: float, radio: float, _fuerza: float, _primario: bool) -> void:
	Audio.tocar_una_vez_por_cuadro(Audio.libreria.explosion_gp)
	var estallido: Estallido = _estallidos.pop_front()
	_estallidos.push_back(estallido)
	estallido.explotar(posicion + Vector2(0, -altura), radio, jugador.params.anim_perspectiva)
