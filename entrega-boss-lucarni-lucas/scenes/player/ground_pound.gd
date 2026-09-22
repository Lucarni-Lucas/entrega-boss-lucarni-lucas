extends Node2D

signal anticipo
signal impacto(posicion: Vector2, altura_inicial: float)

const estado := Player.Estado.GROUND_POUND

var _tiempo_anticipacion := 0.0
var _tiempo_hitbox := 0.0
var _altura_inicial := 0.0

@onready var _hitbox: Hitbox = $Hitbox
@onready var _poligono: CollisionPolygon2D = $Hitbox/CollisionPolygon2D


func procesar_fisica(player: Player, delta: float) -> void:
	_actualizar_hitbox(delta)
	if player.verbo_activo == self:
		_procesar_caida(player, delta)
	elif Input.is_action_just_pressed("ground_pound"):
		player.intentar_activar(self)


func estados_validos() -> Array:
	return [Player.Estado.EN_AIRE]


func esta_disponible(player: Player) -> bool:
	return player.z >= player.params.gp_altura_minima


func puede_interrumpir(_otro: Node) -> bool:
	return false


func activar(player: Player) -> void:
	_altura_inicial = player.z
	_tiempo_anticipacion = player.params.gp_anticipacion
	player.velocidad_z = 0.0
	player.escala_gravedad = 0.0
	anticipo.emit()


func cancelar(player: Player) -> void:
	player.escala_gravedad = 1.0


func _procesar_caida(player: Player, delta: float) -> void:
	player.velocity = Vector2.ZERO
	if _tiempo_anticipacion > 0.0:
		_tiempo_anticipacion -= delta
		if _tiempo_anticipacion <= 0.0:
			player.escala_gravedad = 1.0
			player.aplicar_impulso_vertical(-player.params.gp_velocidad)
		return
	if player.esta_en_suelo():
		_impactar(player)


func _impactar(player: Player) -> void:
	player.liberar_verbo(self)
	var radio := player.params.gp_radio_impacto + player.params.gp_radio_explosion
	_poligono.polygon = Formas.elipse(radio, player.params.anim_perspectiva)
	_hitbox.dano = player.params.gp_dano
	_hitbox.z_min = player.z
	_hitbox.z_max = player.z + player.params.alto_cuerpo
	_hitbox.activar()
	_tiempo_hitbox = player.params.gp_impacto_duracion
	impacto.emit(player.global_position, _altura_inicial)


func _actualizar_hitbox(delta: float) -> void:
	if _tiempo_hitbox <= 0.0:
		return
	_tiempo_hitbox -= delta
	if _tiempo_hitbox <= 0.0:
		_hitbox.desactivar()
