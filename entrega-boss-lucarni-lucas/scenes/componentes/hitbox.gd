extends Area2D
class_name Hitbox

signal golpeo(hurtbox: Hurtbox)

enum Origen { NINGUNO, SLASH, GROUND_POUND, PROYECTIL }

@export var dano := 1
@export var z_min := 0.0
@export var z_max := 20.0
@export var continua := false
@export_range(0.05, 2, 0.05, "suffix:s") var intervalo := 0.4
@export var por_objetivo := false
@export var empuje := 0.0
@export var origen: Origen = Origen.NINGUNO

var _tiempo := 0.0
var activa := false
var _ya_golpeados: Array[Hurtbox] = []
var _desde_golpe: Dictionary[Hurtbox, float] = {}
var _esperando_fisica := false


func activar() -> void:
	activa = true
	_tiempo = 0.0
	_ya_golpeados.clear()
	_desde_golpe.clear()
	_esperando_fisica = true


func desactivar() -> void:
	activa = false
	_ya_golpeados.clear()
	_desde_golpe.clear()


func _physics_process(delta: float) -> void:
	if not activa:
		return
	## Las superposiciones de este frame todavía son de la forma anterior.
	if _esperando_fisica:
		_esperando_fisica = false
		return
	if continua and por_objetivo:
		_vencer_golpes(delta)
	elif continua:
		_tiempo += delta
		if _tiempo >= intervalo:
			_tiempo = 0.0
			_ya_golpeados.clear()
	for area in get_overlapping_areas():
		if area is Hurtbox and _puede_golpear(area):
			_ya_golpeados.append(area)
			if por_objetivo:
				_desde_golpe[area as Hurtbox] = 0.0
			area.recibir_golpe(self)
			golpeo.emit(area)


func _vencer_golpes(delta: float) -> void:
	for hurtbox in _desde_golpe.keys():
		_desde_golpe[hurtbox] += delta
		if _desde_golpe[hurtbox] >= intervalo:
			_desde_golpe.erase(hurtbox)
			_ya_golpeados.erase(hurtbox)


func _puede_golpear(hurtbox: Hurtbox) -> bool:
	if hurtbox in _ya_golpeados:
		return false
	return Altura.rangos_se_tocan(z_min, z_max, hurtbox.z_min, hurtbox.z_max)
