extends CharacterBody2D
class_name Enemigo

signal murio(posicion: Vector2, origen: Hitbox.Origen)
signal termino(enemigo: Enemigo)

@export var params: EnemyParams

var z := 0.0
var vida: int
var jugador: Player
var muerto := false
var _empuje := Vector2.ZERO
var punto := Vector2.ZERO
var _capa: int
var _tween_muerte: Tween

@onready var _sombra: Sombra = $Sombra
@onready var _sprite := $Sprite
@onready var _hurtbox: Hurtbox = $Hurtbox
@onready var _visual: AnimatedSprite2D = $Sprite/Visual
@onready var _hitbox: Hitbox = $Hitbox


func _ready() -> void:
	_capa = collision_layer
	_visual.modulate = params.color
	z = params.altura_vuelo
	_hurtbox.z_min = z
	_hurtbox.z_max = z + params.alto
	_hurtbox.golpeado.connect(_on_golpeado)
	_hitbox.dano = params.dano_contacto
	_hitbox.z_min = z
	_hitbox.z_max = z + params.alto
	_hitbox.continua = true
	_hitbox.intervalo = params.intervalo_contacto
	jugador = get_tree().get_first_node_in_group(Player.GRUPO) as Player
	activar_en(global_position)


func activar_en(posicion: Vector2) -> void:
	global_position = posicion
	vida = params.vida_max
	muerto = false
	_empuje = Vector2.ZERO
	punto = Vector2.ZERO
	modulate = Color.WHITE
	collision_layer = _capa
	_hurtbox.monitorable = true
	_hitbox.activar()
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	_visual.set_frame_and_progress(randi() % _visual.sprite_frames.get_frame_count(_visual.animation), randf())


func desactivar() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED
	_hitbox.desactivar()
	if _tween_muerte:
		_tween_muerte.kill()


func _physics_process(delta: float) -> void:
	_empuje = _empuje.move_toward(Vector2.ZERO, params.frenado_empuje * delta)
	_sprite.position.y = -z
	_sombra.actualizar(z)
	_mirar_al_jugador()
	_animar()


func recibir_dano(cantidad: int, origen := Hitbox.Origen.NINGUNO) -> void:
	vida -= cantidad
	if vida <= 0:
		morir(origen)


func morir(origen := Hitbox.Origen.NINGUNO) -> void:
	if muerto:
		return
	muerto = true
	murio.emit(global_position, origen)
	_hitbox.desactivar()
	_hurtbox.set_deferred("monitorable", false)
	set_deferred("collision_layer", 0)
	_tween_muerte = create_tween()
	_tween_muerte.tween_property(self, "modulate:a", 0.0, params.duracion_muerte)
	_tween_muerte.tween_callback(_terminar_muerte)


func _terminar_muerte() -> void:
	if termino.get_connections().is_empty():
		queue_free()
	else:
		termino.emit(self)


func _on_golpeado(hitbox: Hitbox) -> void:
	var direccion := hitbox.global_position.direction_to(global_position)
	if direccion == Vector2.ZERO:
		direccion = Vector2.from_angle(randf() * TAU)
	_empuje += direccion * hitbox.empuje
	recibir_dano(hitbox.dano, hitbox.origen)
	if vida <= 0:
		return
	modulate = Color.RED
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.2)


func velocidad_externa() -> Vector2:
	return _empuje


func destino() -> Vector2:
	return jugador.global_position + punto


func _mirar_al_jugador() -> void:
	if jugador == null:
		return
	var dx := jugador.global_position.x - global_position.x
	if absf(dx) > 4.0:
		_visual.flip_h = dx < 0.0


## Solo los enemigos con animaciones "caminar" y "atacar" cambian según si se mueven.
func _animar() -> void:
	if muerto or not _visual.sprite_frames.has_animation(&"atacar"):
		return
	var rapidez := velocity.length()
	var animacion := &"caminar" if rapidez > params.velocidad * 0.2 else &"atacar"
	if _visual.animation != animacion:
		_visual.play(animacion)
	if animacion == &"caminar":
		var fps := _visual.sprite_frames.get_animation_speed(animacion)
		_visual.speed_scale = rapidez / (params.avance_por_frame * fps)
	else:
		_visual.speed_scale = 1.0
