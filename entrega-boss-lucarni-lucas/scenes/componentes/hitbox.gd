extends Area2D
class_name Hitbox

signal golpeo(hurtbox: Hurtbox)

@export var dano := 1
@export var z_min := 0.0
@export var z_max := 20.0

var activa := false
var _ya_golpeados: Array[Hurtbox] = []
var _esperando_fisica := false


func activar() -> void:
	activa = true
	_ya_golpeados.clear()
	_esperando_fisica = true


func desactivar() -> void:
	activa = false
	_ya_golpeados.clear()


func _physics_process(_delta: float) -> void:
	if not activa:
		return
	## Las superposiciones de este frame todavía son de la forma anterior.
	if _esperando_fisica:
		_esperando_fisica = false
		return
	for area in get_overlapping_areas():
		if area is Hurtbox and _puede_golpear(area):
			_ya_golpeados.append(area)
			area.recibir_golpe(self)
			golpeo.emit(area)


func _puede_golpear(hurtbox: Hurtbox) -> bool:
	if hurtbox in _ya_golpeados:
		return false
	return Altura.rangos_se_tocan(z_min, z_max, hurtbox.z_min, hurtbox.z_max)
