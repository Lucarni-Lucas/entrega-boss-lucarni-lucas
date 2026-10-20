extends Node2D

@export var textura_suelo: Texture2D
@export var textura_aire: Texture2D

var _tween: Tween
var _paso := 0.0
var _escala_paso := Vector2.ONE
var _deformacion := Vector2.ONE:
	set(valor):
		_deformacion = valor
		scale = _deformacion * _escala_paso

@onready var _estiramiento := $Estiramiento
@onready var _visual := $Estiramiento/Visual
@onready var _self_modulate_base: Color = _visual.self_modulate
@onready var _ojos := $Estiramiento/Visual/Ojos


func deformar(escala: Vector2, duracion_ida: float, duracion_vuelta: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "_deformacion", escala, duracion_ida)
	_tween.tween_property(self, "_deformacion", Vector2.ONE, duracion_vuelta).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func caminar(rapidez: float, params: PlayerParams) -> void:
	var caminando := rapidez > 0.0
	if not caminando and _paso > 0.0:
		rapidez = params.velocidad
	_paso += rapidez * get_physics_process_delta_time() / params.anim_paso_distancia
	if _paso >= 1.0:
		_paso = fmod(_paso, 1.0) if caminando else 0.0
	_escala_paso = Vector2.ONE.lerp(params.anim_paso_escala, (1.0 - cos(_paso * TAU)) / 2.0)
	scale = _deformacion * _escala_paso


func estirar_segun_velocidad(velocidad: Vector2, params: PlayerParams) -> void:
	var factor := minf(1.0 + velocidad.length() * params.anim_estiramiento_factor, params.anim_estiramiento_max)
	_estiramiento.rotation = velocidad.angle()
	_estiramiento.scale = Vector2(factor, 1.0 / factor)
	_visual.rotation = -_estiramiento.rotation


func mostrar_fatiga(fuerza: float, desaturacion: float, brillo: float) -> void:
	var fatiga := 1.0 - fuerza
	_visual.material.set_shader_parameter("desaturacion", desaturacion * fatiga)
	_visual.material.set_shader_parameter("brillo", brillo * fatiga)


func destellar(duracion: float) -> void:
	_visual.self_modulate = Color(2, 2, 2, _self_modulate_base.a)
	create_tween().tween_property(_visual, "self_modulate", _self_modulate_base, duracion)


func cambiar_forma(en_suelo: bool) -> void:
	_visual.texture = textura_suelo if en_suelo else textura_aire


func mirar(direccion: Vector2, velocidad: Vector2, en_suelo: bool) -> void:
	_ojos.actualizar(direccion, velocidad, en_suelo)
