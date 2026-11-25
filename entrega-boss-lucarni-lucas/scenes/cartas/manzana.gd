extends Node2D
class_name Manzana

enum Tipo { VERDE, ROJA }

@export var textura_verde: Texture2D
@export var textura_roja: Texture2D
@export var color_verde := Color("7be35a")
@export var color_roja := Color("ff5a46")
@export_range(0, 40, 0.5, "suffix:px") var vaiven := 6.0
@export_range(0, 10, 0.1, "suffix:Hz") var frecuencia_vaiven := 1.4
@export_group("Estela")
@export_range(0, 1, 0.05, "suffix:s") var largo_estela := 0.35
@export_range(0, 60, 0.5, "suffix:px") var radio_estela := 18.0
@export_range(0, 1, 0.01) var alfa_estela := 0.12
@export_group("Aureola")
@export var color_aureola := Color("ffd65c")
@export var color_borde_aureola := Color("202024")
@export var tamano_aureola := Vector2(18, 6)
@export_range(0, 20, 0.5, "suffix:px") var ancho_aureola := 3.5
@export_range(0, 20, 0.5, "suffix:px") var ancho_borde_aureola := 7.0

var tipo := Tipo.VERDE
var _jugador: Player
var _direccion := 1.0
var _hasta_x := 0.0
var _tiempo := 0.0
var _puntos := PackedVector2Array()

@onready var _sombra: Sombra = $Sombra
@onready var _cuerpo: Node2D = $Cuerpo
@onready var _aura: Sprite2D = $Cuerpo/Aura
@onready var _sprite: Sprite2D = $Cuerpo/Sprite
@onready var _aureola: Node2D = $Cuerpo/Aureola
@onready var _hitbox: Hitbox = $Hitbox
@onready var _forma: CollisionPolygon2D = $Hitbox/Forma


func _ready() -> void:
	_aureola.draw.connect(_dibujar_aureola)
	apagar()


func lanzar(jugador: Player, nuevo_tipo: Tipo, desde: Vector2, hasta_x: float) -> void:
	_jugador = jugador
	tipo = nuevo_tipo
	global_position = desde
	_hasta_x = hasta_x
	_direccion = signf(hasta_x - desde.x)
	_tiempo = randf() * 10.0
	_puntos.clear()
	_sprite.texture = textura_verde if tipo == Tipo.VERDE else textura_roja
	_aura.modulate = color()
	var params := jugador.params
	_forma.polygon = Formas.elipse(params.manzanas_radio, params.anim_perspectiva)
	_hitbox.dano = params.manzanas_dano
	if tipo == Tipo.ROJA:
		_hitbox.activar()
	else:
		_hitbox.desactivar()
	_mover(0.0)
	show()
	set_physics_process(true)


func color() -> Color:
	return color_verde if tipo == Tipo.VERDE else color_roja


func activa() -> bool:
	return visible


func apagar() -> void:
	hide()
	set_physics_process(false)
	_hitbox.desactivar()
	_puntos.clear()


func _physics_process(delta: float) -> void:
	_mover(delta)
	if tipo == Tipo.VERDE and _toca_al_jugador():
		_jugador.curar(_jugador.params.manzanas_curacion)
		apagar()
		return
	if (global_position.x - _hasta_x) * _direccion >= 0.0:
		apagar()


func _mover(delta: float) -> void:
	var params := _jugador.params
	_tiempo += delta
	global_position.x += _direccion * params.manzanas_velocidad * delta
	var z := params.manzanas_altura + sin(_tiempo * TAU * frecuencia_vaiven) * vaiven
	_cuerpo.position.y = -z
	_sombra.actualizar(z)
	_hitbox.z_min = z
	_hitbox.z_max = z + params.manzanas_alto
	_puntos.append(_cuerpo.global_position)
	var maximo := maxi(roundi(largo_estela * Engine.physics_ticks_per_second), 1)
	if _puntos.size() > maximo:
		_puntos = _puntos.slice(_puntos.size() - maximo)
	queue_redraw()
	_aureola.queue_redraw()


func _toca_al_jugador() -> bool:
	if _jugador.vida <= 0:
		return false
	for area in _hitbox.get_overlapping_areas():
		var hurtbox := area as Hurtbox
		if hurtbox and hurtbox.get_parent() == _jugador and Altura.rangos_se_tocan(_hitbox.z_min, _hitbox.z_max, hurtbox.z_min, hurtbox.z_max):
			return true
	return false


func _draw() -> void:
	var cantidad := _puntos.size()
	for i in cantidad:
		var avance := float(i + 1) / cantidad
		draw_circle(to_local(_puntos[i]), radio_estela * avance, Color(color(), alfa_estela * avance))


func _dibujar_aureola() -> void:
	var puntos := Formas.elipse(tamano_aureola.x, tamano_aureola.y / tamano_aureola.x, 32)
	puntos.append(puntos[0])
	_aureola.draw_polyline(puntos, color_borde_aureola, ancho_borde_aureola, true)
	_aureola.draw_polyline(puntos, color_aureola, ancho_aureola, true)
