extends Evento

@export_range(0, 10, 0.1, "suffix:s") var espera_victoria := 2.5
@export_range(0, 40, 0.5, "suffix:px") var temblor_enemigos := 8.0
@export_range(0, 30, 0.5, "suffix:s") var proteccion := 10.0

var _spawner: Spawner
var _jefe: Jefe
var _otros: Array[Enemigo] = []


func _ready() -> void:
	_spawner = get_tree().get_first_node_in_group(Spawner.GRUPO) as Spawner
	_spawner.enemigo_aparecio.connect(_on_enemigo_aparecio)
	set_process(false)


func _on_enemigo_aparecio(enemigo: Enemigo) -> void:
	if enemigo is Jefe:
		_jefe = enemigo
		_jefe.murio.connect(_on_jefe_murio, CONNECT_ONE_SHOT)
		_jefe.exploto.connect(_on_jefe_exploto, CONNECT_ONE_SHOT)


func _on_jefe_murio(_posicion: Vector2, _origen: Hitbox.Origen) -> void:
	_spawner.detener()
	get_parent().detener_reloj()
	var jugador := get_tree().get_first_node_in_group(Player.GRUPO) as Player
	if jugador:
		jugador.proteger(proteccion)
	_otros.clear()
	for enemigo in _spawner.enemigos_activos():
		if enemigo != _jefe and not enemigo.muerto:
			enemigo.ralentizar(0.0, proteccion)
			_otros.append(enemigo)
	set_process(true)


func _process(_delta: float) -> void:
	var avance := _jefe.avance_muerte()
	for enemigo in _otros:
		if is_instance_valid(enemigo) and not enemigo.muerto:
			enemigo.agitar(avance * avance * temblor_enemigos)


func _on_jefe_exploto() -> void:
	set_process(false)
	for enemigo in _otros:
		if is_instance_valid(enemigo) and not enemigo.muerto:
			enemigo.agitar(0.0)
			enemigo.morir()
	_otros.clear()
	get_tree().create_timer(espera_victoria, false, true).timeout.connect(_ganar)


func _ganar() -> void:
	get_parent().terminar_ronda_ya()
