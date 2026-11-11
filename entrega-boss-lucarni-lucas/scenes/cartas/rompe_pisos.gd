extends EfectoCarta

@export var escena_zona: PackedScene
@export var tamano_pool := 32
@export_range(0, 50, 1, "suffix:px") var altura_maxima := 4.0
@export_flags_2d_physics var mascara_enemigos := 4
@export_range(1, 6, 1) var cuadros_entre_revisiones := 2

var _zonas: Array[ZonaRompePisos] = []
var _circulo := CircleShape2D.new()
var _consulta := PhysicsShapeQueryParameters2D.new()


func _ready() -> void:
	_consulta.shape = _circulo
	_consulta.collision_mask = mascara_enemigos
	_consulta.collide_with_areas = true
	_consulta.collide_with_bodies = false
	for i in tamano_pool:
		var zona: ZonaRompePisos = escena_zona.instantiate()
		add_child(zona)
		_zonas.append(zona)
	jugador.impacto_gp.connect(_on_impacto_gp)
	jugador.volvio_al_inicio.connect(_cerrar_todas)


func zonas_activas() -> Array[ZonaRompePisos]:
	var activas: Array[ZonaRompePisos] = []
	activas.assign(_zonas.filter(func(zona: ZonaRompePisos) -> bool: return zona.activa()))
	return activas


func _on_impacto_gp(posicion: Vector2, altura: float, radio: float, _fuerza: float, _primario: bool) -> void:
	if altura > altura_maxima:
		return
	var params := jugador.params
	var zona: ZonaRompePisos = _zonas.pop_front()
	_zonas.push_back(zona)
	zona.abrir(posicion, radio * params.rompe_pisos_escala, params.anim_perspectiva, params.rompe_pisos_duracion)
	Audio.tocar_una_vez_por_cuadro(Audio.libreria.rompe_pisos)


func _physics_process(_delta: float) -> void:
	if Engine.get_physics_frames() % cuadros_entre_revisiones != 0:
		return
	for zona in _zonas:
		if zona.activa():
			_frenar_en(zona)


func _frenar_en(zona: ZonaRompePisos) -> void:
	var params := jugador.params
	_circulo.radius = zona.radio
	_consulta.transform = Transform2D(0.0, zona.global_position)
	for resultado in jugador.get_world_2d().direct_space_state.intersect_shape(_consulta, 128):
		var hurtbox := resultado.collider as Hurtbox
		if hurtbox == null:
			continue
		var enemigo := hurtbox.get_parent() as Enemigo
		if enemigo == null or enemigo.muerto or enemigo.params.altura_vuelo > 0.0:
			continue
		if zona.contiene(enemigo.global_position):
			enemigo.ralentizar(params.rompe_pisos_velocidad, params.rompe_pisos_rastro)


func _cerrar_todas() -> void:
	for zona in _zonas:
		zona.cerrar()
