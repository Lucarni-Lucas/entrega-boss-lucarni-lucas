extends CharacterBody2D
class_name Player

signal aterrizo
signal reboto

enum Estado { EN_SUELO, EN_AIRE, DIVE, GROUND_POUND, VAULT, THROW }

@export var params: PlayerParams

var ultima_direccion := Vector2.DOWN
var z := 0.0
## Positiva sube, negativa baja.
var velocidad_z := 0.0
var tiene_boomerang := true
var verbo_activo: VerboExclusivo = null
var escala_gravedad := 1.0

@onready var _walk := $Walk
@onready var _sprite := $Sprite
@onready var _shadow := $Shadow
@onready var _jump := $Jump
@onready var _slash := $Slash
@onready var _ground_pound := $GroundPound
@onready var _dive := $Dive
@onready var _boomerang := $Boomerang


func _ready() -> void:
	_ground_pound.anticipo.connect(_on_anticipo_gp)
	_ground_pound.impacto.connect(_on_impacto_gp)


func _physics_process(delta: float) -> void:
	_walk.procesar_fisica(self, delta)
	_jump.procesar_fisica(self, delta)
	_ground_pound.procesar_fisica(self, delta)
	_dive.procesar_fisica(self, delta)
	_boomerang.procesar_fisica(self, delta)
	move_and_slide()

	_actualizar_altura(delta)
	_sprite.position.y = -z
	_slash.procesar_fisica(self, delta)
	_shadow.actualizar(z, params)
	_sprite.estirar_segun_velocidad(_velocidad_en_pantalla(), params)


## Altura del suelo debajo del jugador.
func suelo_actual() -> float:
	return 0.0


func esta_en_suelo() -> bool:
	return z <= suelo_actual() + 0.01


## x es el punto más alto (el blob), y el más bajo (la sombra).
func extremos_verticales() -> Vector2:
	var abajo := global_position.y
	return Vector2(abajo - z - params.alto_cuerpo, abajo)


func aplicar_impulso_vertical(fuerza: float) -> void:
	velocidad_z = fuerza


func rebotar(fuerza: float) -> void:
	if verbo_activo != null:
		verbo_activo.cancelar(self)
		verbo_activo = null
	escala_gravedad = 1.0
	aplicar_impulso_vertical(fuerza)
	reboto.emit()


func estado_actual() -> Estado:
	if verbo_activo != null:
		return verbo_activo.estado()
	return Estado.EN_SUELO if esta_en_suelo() else Estado.EN_AIRE


func intentar_activar(verbo: VerboExclusivo) -> bool:
	if not verbo.estados_validos().has(estado_actual()):
		return false
	if not verbo.esta_disponible(self):
		return false
	if verbo_activo != null:
		if not verbo.puede_interrumpir(verbo_activo):
			return false
		verbo_activo.cancelar(self)
	verbo_activo = verbo
	verbo.activar(self)
	return true


func liberar_verbo(verbo: VerboExclusivo) -> void:
	if verbo_activo == verbo:
		verbo_activo = null


func agregar_al_mundo(nodo: Node) -> void:
	get_parent().add_child(nodo)


func _velocidad_en_pantalla() -> Vector2:
	if esta_en_suelo():
		return Vector2.ZERO
	return Vector2(velocity.x, velocity.y - velocidad_z)


func _actualizar_altura(delta: float) -> void:
	if esta_en_suelo() and velocidad_z <= 0.0:
		return
	velocidad_z -= params.gravedad * escala_gravedad * delta
	z += velocidad_z * delta
	if z <= suelo_actual():
		z = suelo_actual()
		velocidad_z = 0.0
		aterrizo.emit()


func _on_aterrizo() -> void:
	_sprite.deformar(params.anim_aterrizaje_escala, params.anim_aterrizaje_ida, params.anim_aterrizaje_vuelta)


func _on_anticipo_gp() -> void:
	_sprite.deformar(params.anim_gp_anticipo_escala, params.gp_anticipacion, params.anim_gp_anticipo_vuelta)


func _on_impacto_gp(_posicion: Vector2, _altura_inicial: float) -> void:
	_sprite.deformar(params.anim_gp_impacto_escala, params.anim_gp_impacto_ida, params.anim_gp_impacto_vuelta)


func _on_reboto() -> void:
	_sprite.deformar(params.anim_rebote_escala, params.anim_rebote_ida, params.anim_rebote_vuelta)
