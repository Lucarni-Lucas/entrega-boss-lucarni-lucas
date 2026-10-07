extends VerboExclusivo

signal lanzo


const _INTERRUMPIBLES := [Player.Estado.GROUND_POUND, Player.Estado.DIVE]

@export var escena_boomerang: PackedScene
@export var radio_en_mano := 34.0
@export var escala_guardado := 0.7
@export var alpha_guardado := 0.35
@export_range(0, 1, 0.01) var perfil_minimo := 0.12
@export_range(-180, 180, 5, "suffix:°") var rotacion_textura := 45.0

@onready var _en_mano: Node2D = $EnMano
@onready var _visual_mano: Sprite2D = $EnMano/Visual
@onready var _offset_en_mano: Vector2 = _en_mano.position
@onready var _escala_visual: Vector2 = _visual_mano.scale

var _tiempo_recuperacion := 0.0
var _proyectil: Boomerang


func _ready() -> void:
	_crear_proyectil.call_deferred(get_parent())


func estado() -> Player.Estado:
	return Player.Estado.THROW


func procesar_fisica(player: Player, delta: float) -> void:
	_actualizar_disponibilidad(player)
	if player.verbo_activo == self:
		_tiempo_recuperacion -= delta
		if _tiempo_recuperacion <= 0.0:
			player.escala_gravedad = 1.0
			player.liberar_verbo(self)
	elif Input.is_action_just_pressed("boomerang"):
		player.intentar_activar(self)
	_actualizar_visual(player)


func estados_validos() -> Array:
	return [Player.Estado.EN_SUELO, Player.Estado.EN_AIRE, Player.Estado.GROUND_POUND, Player.Estado.DIVE]


func esta_disponible(player: Player) -> bool:
	return player.tiene_boomerang


func puede_interrumpir(otro: VerboExclusivo) -> bool:
	return otro.estado() in _INTERRUMPIBLES


func activar(player: Player) -> void:
	_proyectil.lanzar(player, player.ultima_direccion)
	player.tiene_boomerang = false
	_tiempo_recuperacion = player.params.throw_duracion
	player.escala_gravedad = player.params.throw_escala_gravedad
	player.velocidad_z = 0.0
	lanzo.emit()


func cancelar(player: Player) -> void:
	player.escala_gravedad = 1.0


func _actualizar_disponibilidad(player: Player) -> void:
	if _proyectil.en_vuelo:
		return
	if player.esta_en_suelo():
		player.tiene_boomerang = true


func _crear_proyectil(player: Player) -> void:
	_proyectil = escena_boomerang.instantiate()
	player.agregar_al_mundo(_proyectil)
	_proyectil.precalentar(player.global_position)


func _actualizar_visual(player: Player) -> void:
	_en_mano.visible = not _proyectil.en_vuelo and not player.esta_slasheando()
	if not _en_mano.visible:
		return
	var base := _offset_en_mano + Vector2(0, -player.z)
	var mirada := player.ultima_direccion.angle()
	if player.tiene_boomerang:
		_mostrar_en_mano(player, base, mirada + PI / 2.0)
	else:
		_mostrar_guardado(base, mirada)


func _mostrar_en_mano(player: Player, base: Vector2, angulo: float) -> void:
	var achatado := Vector2(cos(angulo), sin(angulo) * player.params.anim_perspectiva)
	_en_mano.position = base + achatado * radio_en_mano
	_en_mano.z_index = -1 if sin(angulo) < 0.0 else 0
	_visual_mano.rotation = 0.0
	## Placa vertical girando: de frente se ve entera, de costado casi una línea.
	var perfil := sin(angulo)
	if absf(perfil) < perfil_minimo:
		perfil = perfil_minimo if perfil >= 0.0 else -perfil_minimo
	_visual_mano.scale = Vector2(_escala_visual.x * perfil, _escala_visual.y)
	_visual_mano.modulate.a = 1.0


func _mostrar_guardado(base: Vector2, mirada: float) -> void:
	_en_mano.position = base
	_en_mano.z_index = 0
	_visual_mano.rotation = mirada + deg_to_rad(rotacion_textura)
	_visual_mano.scale = _escala_visual * escala_guardado
	_visual_mano.modulate.a = alpha_guardado
