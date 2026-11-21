extends EfectoCarta

@export var escena_manzana: PackedScene
@export var cantidad := 3
@export_range(0, 600, 5, "suffix:px") var margen := 140.0
@export_range(0, 600, 5, "suffix:px") var afuera := 120.0

var _manzanas: Array[Manzana] = []
var _espera := 0.0
var _area := Rect2()


func _ready() -> void:
	var spawner := get_tree().get_first_node_in_group(Spawner.GRUPO) as Spawner
	if spawner:
		_area = spawner.area
	for i in cantidad:
		var manzana: Manzana = escena_manzana.instantiate()
		jugador.get_parent().add_child.call_deferred(manzana)
		_manzanas.append(manzana)
	_esperar()
	jugador.volvio_al_inicio.connect(_reiniciar)


func manzanas_activas() -> Array[Manzana]:
	var activas: Array[Manzana] = []
	activas.assign(_manzanas.filter(func(manzana: Manzana) -> bool: return manzana.is_inside_tree() and manzana.activa()))
	return activas


func lanzar(tipo: Manzana.Tipo, desde_la_izquierda: bool, y: float) -> Manzana:
	var manzana: Manzana = _manzanas.pop_front()
	_manzanas.push_back(manzana)
	var izquierda := _area.position.x - afuera
	var derecha := _area.end.x + afuera
	var desde := Vector2(izquierda if desde_la_izquierda else derecha, y)
	manzana.lanzar(jugador, tipo, desde, derecha if desde_la_izquierda else izquierda)
	return manzana


func _physics_process(delta: float) -> void:
	_espera -= delta
	if _espera > 0.0:
		return
	_esperar()
	if not _area.has_area():
		return
	var tipo := Manzana.Tipo.VERDE if randf() < jugador.params.manzanas_chance_verde else Manzana.Tipo.ROJA
	lanzar(tipo, randf() < 0.5, randf_range(_area.position.y + margen, _area.end.y - margen))


func _esperar() -> void:
	_espera = randf_range(jugador.params.manzanas_cada_min, jugador.params.manzanas_cada_max)


func _reiniciar() -> void:
	_esperar()
	for manzana in _manzanas:
		if manzana.is_inside_tree():
			manzana.apagar()
