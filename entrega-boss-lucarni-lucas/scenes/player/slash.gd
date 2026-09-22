extends Node2D

signal slasheo

const _SEGMENTOS_ARCO := 8

const _ESTADOS_VALIDOS := [Player.Estado.EN_SUELO, Player.Estado.EN_AIRE, Player.Estado.DIVE]

var _tiempo_activo := 0.0
var _tiempo_cooldown := 0.0
var _angulo_centro := 0.0
var _sentido := 1.0
var _tween_estela: Tween

@onready var _hitbox: Hitbox = $Hitbox
@onready var _efecto := $Efecto
@onready var _estela: Line2D = $Efecto/Estela
@onready var _filo := $Efecto/Filo
@onready var _offset_efecto: Vector2 = _efecto.position
@onready var _poligono: CollisionPolygon2D = $Hitbox/CollisionPolygon2D
@onready var _mitad_filo: float = _filo.texture.get_width() / 2.0


func procesar_fisica(player: Player, delta: float) -> void:
	_tiempo_cooldown = maxf(_tiempo_cooldown - delta, 0.0)

	if _tiempo_activo > 0.0:
		_tiempo_activo -= delta
		_seguir_altura(player)
		_barrer(player)
		if _tiempo_activo <= 0.0:
			_terminar(player)
	elif Input.is_action_just_pressed("slash") and esta_disponible(player):
		_iniciar(player)


func esta_disponible(player: Player) -> bool:
	return player.estado_actual() in _ESTADOS_VALIDOS and player.tiene_boomerang and _tiempo_cooldown <= 0.0


func _iniciar(player: Player) -> void:
	var direccion := player.ultima_direccion
	_angulo_centro = direccion.angle()
	_sentido = -_sentido

	_construir_hitbox(player.params)
	_hitbox.dano = player.params.slash_dano
	_hitbox.activar()

	if _tween_estela:
		_tween_estela.kill()
	_estela.clear_points()
	_estela.modulate.a = 1.0
	_efecto.scale = Vector2(1.0, player.params.anim_perspectiva)
	_efecto.visible = true
	_filo.visible = true
	_filo.scale.y = _sentido

	_tiempo_activo = player.params.slash_duracion
	_tiempo_cooldown = player.params.slash_cooldown
	_seguir_altura(player)
	_barrer(player)
	slasheo.emit()


func _construir_hitbox(params: PlayerParams) -> void:
	var mitad_arco := deg_to_rad(params.slash_arco) / 2.0
	var perspectiva := Vector2(1.0, params.anim_perspectiva)
	var puntos := PackedVector2Array([Vector2.ZERO])
	for i in _SEGMENTOS_ARCO + 1:
		var angulo := _angulo_centro + lerpf(-mitad_arco, mitad_arco, float(i) / _SEGMENTOS_ARCO)
		puntos.append(Vector2.from_angle(angulo) * params.slash_alcance * perspectiva)
	_poligono.polygon = puntos


func _seguir_altura(player: Player) -> void:
	_hitbox.z_min = player.z
	_hitbox.z_max = player.z + player.params.alto_cuerpo
	_efecto.position = _offset_efecto + Vector2(0, -player.z)


func _barrer(player: Player) -> void:
	var progreso := clampf(1.0 - _tiempo_activo / player.params.slash_duracion, 0.0, 1.0)
	var mitad_arco := deg_to_rad(player.params.slash_arco) / 2.0
	var angulo := _angulo_centro + _sentido * lerpf(-mitad_arco, mitad_arco, progreso)
	var direccion_punto := Vector2.from_angle(angulo)
	_filo.position = direccion_punto * player.params.slash_radio_efecto
	_filo.rotation = angulo
	_estela.add_point(direccion_punto * (player.params.slash_radio_efecto + _mitad_filo - (_estela.get_width()/2) ))
	## Mitad de atrás del arco: se dibuja detrás del blob.
	_efecto.z_index = 0 if direccion_punto.y >= 0.0 else -1


func _terminar(player: Player) -> void:
	_hitbox.desactivar()
	_filo.visible = false
	_tween_estela = create_tween()
	_tween_estela.tween_property(_estela, "modulate:a", 0.0, player.params.slash_estela_desvanecer)
	_tween_estela.tween_callback(_efecto.hide)
