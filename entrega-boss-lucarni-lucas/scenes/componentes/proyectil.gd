extends Hitbox
class_name Proyectil

signal termino(proyectil: Proyectil)

@export_range(0, 100, 1, "suffix:px") var radio := 9.0

var z := 0.0
var velocidad := Vector2.ZERO
var velocidad_z := 0.0
var gravedad := 0.0
var _restante := 0.0
var _escala := 1.0

@onready var _visual: Node2D = $Visual
@onready var _sombra: Sombra = $Sombra
@onready var _forma: CollisionShape2D = $CollisionShape2D
@onready var _escala_visual: Vector2 = _visual.scale


func lanzar(posicion: Vector2, altura: float, nueva_velocidad: Vector2, nueva_velocidad_z: float, nueva_gravedad: float, duracion: float, nuevo_dano: int, escala := 1.0) -> void:
	_escala = escala
	_forma.scale = Vector2.ONE * escala
	_visual.scale = _escala_visual * escala
	_sombra.agrandar(escala)
	global_position = posicion
	z = altura
	velocidad = nueva_velocidad
	velocidad_z = nueva_velocidad_z
	gravedad = nueva_gravedad
	_restante = duracion
	dano = nuevo_dano
	_actualizar_altura()
	show()
	set_physics_process(true)
	activar()


func desactivar() -> void:
	super()
	hide()
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	var velocidad_z_anterior := velocidad_z
	velocidad_z -= gravedad * delta
	z += (velocidad_z_anterior + velocidad_z) * 0.5 * delta
	global_position += velocidad * delta
	_restante -= delta
	if _restante <= 0.0 or (gravedad > 0.0 and velocidad_z < 0.0 and z <= 0.0):
		termino.emit(self)
		return
	_actualizar_altura()
	super(delta)


func _actualizar_altura() -> void:
	z_min = z - radio * _escala
	z_max = z + radio * _escala
	_visual.position.y = -z
	_sombra.actualizar(z)
