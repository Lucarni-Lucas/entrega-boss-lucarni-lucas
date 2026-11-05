extends EfectoCarta

@export var escena_diamante: PackedScene

var _diamantes: Array[Diamante] = []
var _formas: Array[CollisionPolygon2D] = []
var _angulo := 0.0

@onready var _hitbox: Hitbox = $Hitbox


func _ready() -> void:
	var params := jugador.params
	var forma := Formas.elipse(params.diamantes_radio_golpe, params.anim_perspectiva)
	for i in params.diamantes_cantidad:
		var diamante: Diamante = escena_diamante.instantiate()
		add_child(diamante)
		_diamantes.append(diamante)
		var poligono := CollisionPolygon2D.new()
		poligono.polygon = forma
		_hitbox.add_child(poligono)
		_formas.append(poligono)
	_hitbox.dano = jugador.dano_de(params.diamantes_dano)
	_hitbox.empuje = params.diamantes_empuje
	_hitbox.intervalo = params.diamantes_intervalo
	_hitbox.activar()
	_ubicar()


func _physics_process(delta: float) -> void:
	_angulo = fmod(_angulo + TAU * jugador.params.diamantes_vueltas * delta, TAU)
	_ubicar()


func _ubicar() -> void:
	var params := jugador.params
	var centro := jugador.global_position
	_hitbox.global_position = centro
	_hitbox.z_min = jugador.z
	_hitbox.z_max = jugador.z + params.alto_cuerpo
	for i in _diamantes.size():
		var angulo := _angulo + TAU * i / _diamantes.size()
		var desplazamiento := Vector2(cos(angulo), sin(angulo) * params.anim_perspectiva) * params.diamantes_radio
		_formas[i].position = desplazamiento
		_diamantes[i].ubicar(centro + desplazamiento, jugador.z, sin(angulo) >= 0.0)
