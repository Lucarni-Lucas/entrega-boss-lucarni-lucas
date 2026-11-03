extends Area2D
class_name Boomerang

signal guardado
signal estallo(posicion: Vector2, altura: float)

enum Fase { IDA, FLOTANDO, VUELTA }

@export var destello_radio := 22.0
@export var destello_achatado := 0.45
@export var giro := 9.0
@export_group("Carga")
@export_range(0, 5, 0.1) var latidos_por_segundo := 2.0
@export_range(0, 1, 0.05) var brillo_latido := 0.35
@export_range(0, 100, 1, "suffix:px") var radio_aro := 34.0
@export_range(1, 2, 0.05) var crecimiento_aro := 1.15
@export_range(0, 1, 0.05) var alpha_aro_minimo := 0.25

var params: PlayerParams
var z := 0.0
var cargado := false
var _fuerza_cargada := 0.0

var _fase := Fase.IDA
var _direccion := Vector2.ZERO
var _recorrido := 0.0
var _tiempo_flotando := 0.0
var _duenio: Player
var _angulo := 0.0
var _rebotes := 0
var _armado := false
var en_vuelo := false

@onready var _sprite := $Sprite
@onready var _shadow := $Sombra
@onready var _chispas: GPUParticles2D = $Sprite/Chispas
@onready var _destello: Sprite2D = $Sprite/Destello
@onready var _destello2: Sprite2D = $Sprite/Destello2
@onready var _detector: Area2D = $DetectorJugador
@onready var _hitbox: Hitbox = $Hitbox
@onready var _poligono_hitbox: CollisionPolygon2D = $Hitbox/CollisionPolygon2D
@onready var _visual: Sprite2D = $Sprite/Visual
@onready var _aro: Line2D = $Sprite/Aro
@onready var _offset_sprite: Vector2 = _sprite.position


func _ready() -> void:
	_aro.points = Formas.elipse(radio_aro, destello_achatado, 24)


func _physics_process(delta: float) -> void:
	match _fase:
		Fase.IDA:
			_avanzar(delta)
		Fase.FLOTANDO:
			_flotar(delta)
		Fase.VUELTA:
			_volver(delta)
	_angulo += giro * delta
	_ubicar_destello(_destello, _angulo)
	_ubicar_destello(_destello2, _angulo + PI)
	_sprite.position.y = _offset_sprite.y - z
	_shadow.actualizar(z)
	_hitbox.z_min = z
	_hitbox.z_max = z + params.boomerang_alto
	var latido := pintar_carga(_visual.material)
	_aro.visible = cargado
	_aro.scale = Vector2.ONE * lerpf(1.0, crecimiento_aro, latido)
	_aro.modulate.a = lerpf(alpha_aro_minimo, 1.0, latido)


func cargar(fuerza: float) -> void:
	cargado = true
	_fuerza_cargada = fuerza


func descargar() -> void:
	cargado = false


func pintar_carga(material: ShaderMaterial) -> float:
	var latido := 0.0
	if cargado:
		latido = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * TAU * latidos_por_segundo)
	material.set_shader_parameter("carga", 1.0 if cargado else 0.0)
	material.set_shader_parameter("brillo", brillo_latido * latido)
	return latido


func _on_body_entered(_cuerpo: Node2D) -> void:
	if not en_vuelo:
		return
	if _fase == Fase.IDA:
		_cambiar_fase(Fase.FLOTANDO)


func lanzar(duenio: Player, direccion: Vector2) -> void:
	_duenio = duenio
	params = duenio.params
	_direccion = direccion
	z = duenio.z
	global_position = duenio.global_position
	_recorrido = 0.0
	_tiempo_flotando = 0.0
	_rebotes = 0
	_armado = false
	_poligono_hitbox.polygon = Formas.elipse(params.boomerang_radio_dano, params.anim_perspectiva)
	_angulo = 0.0
	en_vuelo = true
	visible = true
	modulate.a = 1.0
	process_mode = Node.PROCESS_MODE_INHERIT
	set_physics_process(true)
	_cambiar_fase(Fase.IDA)
	if params.boomerang_dano > 0:
		_hitbox.dano = _duenio.dano_de(params.boomerang_dano)
		_hitbox.z_min = z
		_hitbox.z_max = z + params.boomerang_alto
		_hitbox.activar()


func _avanzar(delta: float) -> void:
	var paso := params.boomerang_velocidad * delta
	global_position += _direccion * paso
	_recorrido += paso
	if _recorrido >= params.boomerang_distancia:
		_cambiar_fase(Fase.FLOTANDO)


func _flotar(delta: float) -> void:
	_revisar_rebote()
	_tiempo_flotando += delta
	if _tiempo_flotando >= params.boomerang_duracion:
		_cambiar_fase(Fase.VUELTA)


func _volver(delta: float) -> void:
	var paso := params.boomerang_velocidad_vuelta * delta
	global_position = global_position.move_toward(_duenio.global_position, paso)
	z = move_toward(z, _duenio.z, paso)
	if global_position.distance_to(_duenio.global_position) < paso:
		guardar()


func _cambiar_fase(nueva: Fase) -> void:
	_fase = nueva
	_chispas.emitting = nueva == Fase.FLOTANDO
	_hitbox.continua = nueva == Fase.FLOTANDO


func _ubicar_destello(destello: Sprite2D, angulo: float) -> void:
	destello.position = Vector2(cos(angulo), sin(angulo) * destello_achatado) * destello_radio
	destello.z_index = -1 if sin(angulo) < 0.0 else 1


func _revisar_rebote() -> void:
	var jugador := _jugador_que_rebota()
	if not _armado:
		_armado = jugador == null
		return
	if jugador:
		_rebotar_en(jugador)


func _jugador_que_rebota() -> Player:
	for cuerpo in _detector.get_overlapping_bodies():
		if cuerpo is Player and _puede_rebotar(cuerpo):
			return cuerpo
	return null


func _puede_rebotar(player: Player) -> bool:
	return Altura.rangos_se_tocan(z, z + params.boomerang_alto, player.z, player.z + params.alto_cuerpo)


func _rebotar_en(player: Player) -> void:
	## Desde el suelo es un salto que además devuelve el boomerang a la mano.
	if player.esta_en_suelo():
		player.rebotar(params.fuerza_salto)
		guardar()
		return
	player.rebotar(params.vault_fuerza)
	_rebotes += 1
	_armado = false
	if cargado:
		_estallar(player)
	if _rebotes >= params.boomerang_rebotes_max:
		_cambiar_fase(Fase.VUELTA)


func _estallar(player: Player) -> void:
	cargado = false
	player.impactar_gp(global_position, z, _fuerza_cargada)
	estallo.emit(global_position, z)


func guardar() -> void:
	en_vuelo = false
	_desactivar()
	guardado.emit()


func cancelar() -> void:
	en_vuelo = false
	_desactivar()


func _desactivar() -> void:
	visible = false
	_hitbox.desactivar()
	set_physics_process(false)
	_chispas.restart()
	_chispas.emitting = false


func precalentar(posicion: Vector2) -> void:
	_desactivar()
	global_position = posicion
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = true
	modulate.a = 0.01
	_chispas.emitting = true
	await get_tree().create_timer(0.5).timeout
	if en_vuelo:
		return
	modulate.a = 1.0
	process_mode = Node.PROCESS_MODE_INHERIT
	_desactivar()
