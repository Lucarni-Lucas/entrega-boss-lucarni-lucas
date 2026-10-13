extends Node
class_name Anillos

@export var params: AnillosParams
@export var area := Rect2(0, 0, 2000, 1500)

var _puntos := PackedVector2Array([Vector2.ZERO])
var _inicios := PackedInt32Array([0, 1])
var _enemigos: Array[Enemigo] = []
var _extra_espera: Dictionary[Enemigo, float] = {}
var _jugador: Player
var _tiempo := 0.0
var _pendiente := false


func _ready() -> void:
	_jugador = get_tree().get_first_node_in_group(Player.GRUPO) as Player
	for k in range(1, params.cantidad + 1):
		var radio := params.separacion * k
		var cantidad := floori(TAU * radio / params.ancho_enemigo)
		var corrimiento := 0.5 if k % 2 == 1 else 0.0
		for i in cantidad:
			var angulo := (i + corrimiento) * TAU / cantidad
			_puntos.append(Vector2(cos(angulo), sin(angulo) * params.perspectiva) * radio)
		_inicios.append(_puntos.size())


func _physics_process(delta: float) -> void:
	_tiempo -= delta
	if _pendiente or _tiempo <= 0.0:
		_repartir_todos()


func agregar(enemigo: Enemigo) -> void:
	_enemigos.append(enemigo)
	_extra_espera[enemigo] = randf() * params.franja_espera
	_pendiente = true


func quitar(enemigo: Enemigo) -> void:
	_enemigos.erase(enemigo)
	_extra_espera.erase(enemigo)
	_pendiente = true


func repartir_pronto() -> void:
	_pendiente = true


func _repartir_todos() -> void:
	_pendiente = false
	_tiempo = params.intervalo
	var por_altura: Dictionary[float, Array] = {}
	for enemigo in _enemigos:
		if not enemigo.muerto:
			por_altura.get_or_add(enemigo.z, []).append(enemigo)
	for grupo in por_altura.values():
		_repartir(grupo)


func _repartir(enemigos: Array) -> void:
	var centro := _jugador.global_position
	var escala := Vector2(1.0, 1.0 / params.perspectiva)
	enemigos.sort_custom(func(a: Enemigo, b: Enemigo): return ((a.global_position - centro) * escala).length_squared() < ((b.global_position - centro) * escala).length_squared())
	var libres := _puntos_validos(centro)
	var quedan := libres.count(true)
	for enemigo: Enemigo in enemigos:
		var i := _mas_cercano(libres, enemigo.global_position - centro) if quedan > 0 else -1
		if i == -1:
			enemigo.punto = _punto_de_espera(enemigo, centro)
		else:
			libres[i] = false
			quedan -= 1
			enemigo.punto = _puntos[i]


func _puntos_validos(centro: Vector2) -> Array[bool]:
	var zona := area.grow(-params.margen)
	var libres: Array[bool] = []
	for desplazamiento in _puntos:
		libres.append(zona.has_point(centro + desplazamiento))
	return libres


func _mas_cercano(libres: Array[bool], posicion: Vector2) -> int:
	for k in _inicios.size() - 1:
		var mejor := -1
		for i in range(_inicios[k], _inicios[k + 1]):
			if libres[i] and (mejor == -1 or _puntos[i].distance_squared_to(posicion) < _puntos[mejor].distance_squared_to(posicion)):
				mejor = i
		if mejor != -1:
			return mejor
	return -1


func _punto_de_espera(enemigo: Enemigo, centro: Vector2) -> Vector2:
	var d := enemigo.global_position - centro
	var direccion := Vector2(d.x, d.y / params.perspectiva).normalized()
	var radio := params.separacion * (params.cantidad + 1) + _extra_espera[enemigo]
	return Vector2(direccion.x, direccion.y * params.perspectiva) * radio
