extends Area2D
class_name Boomerang

signal guardado

enum Fase { IDA, FLOTANDO, VUELTA }

const GRUPO := &"boomies"

@export var destello_radio := 22.0
@export var destello_achatado := 0.45
@export var giro := 9.0
@export_range(0, 1, 0.01, "suffix:s") var duracion_desvanecer := 0.2

var params: PlayerParams
var z := 0.0
var vuelve := true

var _fase := Fase.IDA
var _direccion := Vector2.ZERO
var _recorrido := 0.0
var _tiempo_flotando := 0.0
var _duenio: Player
var _angulo := 0.0
var _rebotes := 0
var _armado := false
var _tween_desvanecer: Tween
var en_vuelo := false
var electrizado := false:
	set(valor):
		electrizado = valor
		if is_node_ready():
			_electricidad.visible = valor

@onready var _sprite := $Sprite
@onready var _shadow := $Sombra
@onready var _chispas: GPUParticles2D = $Sprite/Chispas
@onready var _destello: Sprite2D = $Sprite/Destello
@onready var _destello2: Sprite2D = $Sprite/Destello2
@onready var _detector: Area2D = $DetectorJugador
@onready var _hitbox: Hitbox = $Hitbox
@onready var _poligono_hitbox: CollisionPolygon2D = $Hitbox/CollisionPolygon2D
@onready var _electricidad: Electricidad = $Sprite/Electricidad
@onready var _offset_sprite: Vector2 = _sprite.position


func _ready() -> void:
	add_to_group(GRUPO)
	_electricidad.visible = electrizado


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
	if _tween_desvanecer:
		_tween_desvanecer.kill()
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


func esta_flotando() -> bool:
	return en_vuelo and _fase == Fase.FLOTANDO


func _cambiar_fase(nueva: Fase) -> void:
	if nueva == Fase.VUELTA and not vuelve:
		desvanecer()
		return
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
		if vuelve:
			guardar()
		else:
			desvanecer()
		return
	player.rebotar(params.vault_fuerza)
	_rebotes += 1
	_armado = false
	if _rebotes >= params.boomerang_rebotes_max:
		_cambiar_fase(Fase.VUELTA)


func guardar() -> void:
	en_vuelo = false
	_desactivar()
	guardado.emit()


func cancelar() -> void:
	en_vuelo = false
	if _tween_desvanecer:
		_tween_desvanecer.kill()
	_desactivar()


func desvanecer() -> void:
	if not en_vuelo:
		return
	en_vuelo = false
	_hitbox.desactivar()
	_chispas.emitting = false
	set_physics_process(false)
	_tween_desvanecer = create_tween()
	_tween_desvanecer.tween_property(self, "modulate:a", 0.0, duracion_desvanecer)
	_tween_desvanecer.tween_callback(_desactivar)


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
