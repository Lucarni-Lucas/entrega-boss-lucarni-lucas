extends VerboExclusivo

signal anticipo
signal impacto(posicion: Vector2, altura_inicial: float)

var _tiempo_anticipacion := 0.0
var _altura_inicial := 0.0
var _invulnerable := false


func estado() -> Player.Estado:
	return Player.Estado.GROUND_POUND


func procesar_fisica(player: Player, delta: float) -> void:
	if player.verbo_activo == self:
		_procesar_caida(player, delta)
	elif Input.is_action_just_pressed("ground_pound"):
		player.intentar_activar(self)


func estados_validos() -> Array:
	return [Player.Estado.EN_AIRE]


func esta_disponible(player: Player) -> bool:
	return player.z >= player.params.gp_altura_minima


func activar(player: Player) -> void:
	_altura_inicial = player.z
	_tiempo_anticipacion = player.params.gp_anticipacion
	player.velocidad_z = 0.0
	player.escala_gravedad = 0.0
	anticipo.emit()
	_invulnerable = player.fuerza_gp() >= 1.0


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
	var fuerza := player.fuerza_gp()
	if _invulnerable:
		player.proteger(player.params.gp_proteccion)
	player.impactar_gp(player.global_position, player.z, fuerza)
	player.gastar_energia_gp()
	player.mantener_aereo(player.params.gp_salto_ventana)
	impacto.emit(player.global_position, _altura_inicial)


func es_invulnerable() -> bool:
	return _invulnerable
