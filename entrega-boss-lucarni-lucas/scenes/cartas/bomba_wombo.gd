extends Node2D
class_name BombaWombo

signal exploto(bomba: BombaWombo, altura: float)

@export_range(0, 2000, 10, "suffix:px") var altura_inicial := 700.0
@export_range(0, 200, 1, "suffix:px") var alto := 40.0
@export_range(0, 200, 1, "suffix:px") var radio_toque := 40.0
@export var color_chispa := Color("ffd35c")
@export var color_borde_chispa := Color("202024")
@export_range(0, 20, 0.5, "suffix:px") var radio_chispa := 6.0
@export_range(0, 1, 0.05) var aplastado := 0.2
@export_range(0, 1, 0.01, "suffix:s") var duracion_aplastado := 0.15
@export_range(0, 3000, 10, "suffix:px/s") var velocidad_correccion := 900.0

var objetivo: Enemigo
var desvio := Vector2.ZERO
var _meta: Callable
var _radio := 0.0
var _distancia_previa := INF
var _retraso := 0.0
var _caida := 0.45
var _mecha := 0.6
var _tiempo := 0.0
var _z := 0.0
var _en_piso := false
var _voladores: Array[Enemigo] = []
var _perspectiva := 1.0
var _tween: Tween

@onready var _sombra: Sombra = $Sombra
@onready var _cuerpo: Node2D = $Cuerpo
@onready var _sprite: Sprite2D = $Cuerpo/Sprite
@onready var _chispa: Node2D = $Cuerpo/Chispa
@onready var _escala_sprite := _sprite.scale


func _ready() -> void:
	_chispa.draw.connect(_dibujar_chispa)
	apagar()


func lanzar(posicion: Vector2, retraso: float, caida: float, mecha: float, voladores: Array[Enemigo], perspectiva: float) -> void:
	global_position = posicion
	_retraso = retraso
	_caida = maxf(caida, 0.01)
	_mecha = mecha
	_voladores = voladores
	_perspectiva = perspectiva
	_tiempo = 0.0
	_en_piso = false
	_z = altura_inicial
	_poner_altura(_z)
	if _tween:
		_tween.kill()
	_sprite.scale = _escala_sprite
	hide()
	set_physics_process(true)


func apuntar(nuevo_objetivo: Enemigo, nuevo_desvio: Vector2, meta: Callable, radio: float) -> void:
	objetivo = nuevo_objetivo
	desvio = nuevo_desvio
	_meta = meta
	_radio = radio
	_distancia_previa = INF


func tiempo_hasta_explotar() -> float:
	return _retraso + _caida + _mecha - _tiempo


func tiempo_hasta_aire(fraccion: float) -> float:
	return _retraso + _caida * fraccion - _tiempo


func activa() -> bool:
	return is_physics_processing()


func esta_en_piso() -> bool:
	return _en_piso


func altura() -> float:
	return _z


func apagar() -> void:
	hide()
	set_physics_process(false)
	_voladores = []
	objetivo = null
	_meta = Callable()


func _physics_process(delta: float) -> void:
	_tiempo += delta
	if not _en_piso and _meta.is_valid() and is_instance_valid(objetivo) and not objetivo.muerto:
		global_position = global_position.move_toward(_meta.call(self), velocidad_correccion * delta)
	if _tiempo < _retraso:
		return
	show()
	var tiempo := _tiempo - _retraso
	_chispa.scale = Vector2.ONE * randf_range(0.7, 1.25)
	_chispa.rotation = randf() * TAU
	if _en_piso:
		if tiempo >= _caida + _mecha or _se_aleja():
			_explotar()
		return
	var avance := clampf(tiempo / _caida, 0.0, 1.0)
	_z = altura_inicial * (1.0 - avance * avance)
	_poner_altura(_z)
	if _toca_volador():
		_explotar()
	elif avance >= 1.0:
		_aterrizar()


func _se_aleja() -> bool:
	if not is_instance_valid(objetivo) or objetivo.muerto or objetivo.params.altura_vuelo > 0.0:
		return false
	var d := objetivo.global_position - global_position
	var distancia := Vector2(d.x, d.y / _perspectiva).length()
	var se_aleja := distancia <= _radio and distancia > _distancia_previa
	_distancia_previa = distancia
	return se_aleja


func _poner_altura(z: float) -> void:
	_cuerpo.position.y = -z
	_sombra.actualizar(z)


func _aterrizar() -> void:
	_en_piso = true
	_z = 0.0
	_poner_altura(0.0)
	_sprite.scale = _escala_sprite * Vector2(1.0 + aplastado, 1.0 - aplastado)
	_tween = create_tween()
	_tween.tween_property(_sprite, "scale", _escala_sprite, duracion_aplastado).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _toca_volador() -> bool:
	for enemigo in _voladores:
		if not is_instance_valid(enemigo) or enemigo.muerto or not enemigo.visible:
			continue
		if not Altura.rangos_se_tocan(_z, _z + alto, enemigo.z, enemigo.z + enemigo.params.alto):
			continue
		var d := enemigo.global_position - global_position
		if Vector2(d.x, d.y / _perspectiva).length() <= radio_toque:
			return true
	return false


func _explotar() -> void:
	exploto.emit(self, _z)
	apagar()


func _dibujar_chispa() -> void:
	var puntos := PackedVector2Array()
	for i in 10:
		var angulo := TAU * i / 10.0 - PI * 0.5
		puntos.append(Vector2.from_angle(angulo) * radio_chispa * (1.0 if i % 2 == 0 else 0.45))
	var cerrado := puntos.duplicate()
	cerrado.append(puntos[0])
	_chispa.draw_colored_polygon(puntos, color_chispa)
	_chispa.draw_polyline(cerrado, color_borde_chispa, 1.5, true)
