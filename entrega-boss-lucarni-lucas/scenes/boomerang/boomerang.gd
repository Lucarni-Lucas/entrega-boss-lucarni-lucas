extends Area2D
class_name Boomerang

signal guardado

enum Fase { IDA, FLOTANDO, VUELTA }

@export var destello_radio := 22.0
@export var destello_achatado := 0.45
@export var giro := 12.0

var params: PlayerParams
var z := 0.0

var _fase := Fase.IDA
var _direccion := Vector2.ZERO
var _recorrido := 0.0
var _tiempo_flotando := 0.0
var _duenio: Player
var _angulo := 0.0

@onready var _sprite := $Sprite
@onready var _shadow := $Shadow
@onready var _chispas: GPUParticles2D = $Sprite/Chispas
@onready var _destello: Sprite2D = $Sprite/Destello
@onready var _destello2: Sprite2D = $Sprite/Destello2

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(_body: Node2D) -> void:
	if _fase == Fase.IDA:
		_cambiar_fase(Fase.FLOTANDO)


func lanzar(duenio: Player, direccion: Vector2) -> void:
	_duenio = duenio
	params = duenio.params
	_direccion = direccion
	z = duenio.z
	global_position = duenio.global_position


func _physics_process(delta: float) -> void:
	match _fase:
		Fase.IDA:
			_avanzar(delta)
		Fase.FLOTANDO:
			_flotar(delta)
		Fase.VUELTA:
			_volver(delta)
	_angulo += giro * delta
	_destello.z_index = -1 if sin(_angulo) < 0.0 else 1
	_ubicar_destello(_destello, _angulo)
	_ubicar_destello(_destello2, _angulo + PI)
	_sprite.position.y = -z - 16
	_shadow.actualizar(z, params)


func _avanzar(delta: float) -> void:
	var paso := params.boomerang_velocidad * delta
	global_position += _direccion * paso
	_recorrido += paso
	if _recorrido >= params.boomerang_distancia:
		_cambiar_fase(Fase.FLOTANDO)


func _flotar(delta: float) -> void:
	_tiempo_flotando += delta
	if _tiempo_flotando >= params.boomerang_duracion:
		_cambiar_fase(Fase.VUELTA)


func _volver(delta: float) -> void:
	var paso := params.boomerang_velocidad_vuelta * delta
	global_position = global_position.move_toward(_duenio.global_position, paso)
	z = move_toward(z, _duenio.z, paso)
	if global_position.distance_to(_duenio.global_position) < paso:
		guardado.emit()
		queue_free()


func _cambiar_fase(nueva: Fase) -> void:
	_fase = nueva
	_chispas.emitting = nueva == Fase.FLOTANDO


func _ubicar_destello(destello: Sprite2D, angulo: float) -> void:
	destello.position = Vector2(cos(angulo), sin(angulo) * destello_achatado) * destello_radio
	destello.z_index = -1 if sin(angulo) < 0.0 else 1
