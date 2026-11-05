extends Hitbox
class_name ImpactoGp

signal termino(impacto: ImpactoGp)

var radio := 0.0
var _restante := 0.0

@onready var _poligono: CollisionPolygon2D = $CollisionPolygon2D


func golpear(jugador: Player, posicion: Vector2, altura: float, fuerza: float) -> void:
	var params := jugador.params
	global_position = posicion
	var nuevo_radio := (params.gp_radio_impacto + params.gp_radio_explosion) * lerpf(params.gp_radio_min, 1.0, fuerza)
	if nuevo_radio != radio:
		radio = nuevo_radio
		_poligono.polygon = Formas.elipse(radio, params.anim_perspectiva)
	dano = jugador.dano_de(params.gp_dano)
	z_min = altura
	z_max = altura + params.alto_cuerpo
	empuje = params.gp_empuje * lerpf(params.gp_empuje_min, 1.0, fuerza)
	_restante = params.gp_impacto_duracion
	process_mode = Node.PROCESS_MODE_INHERIT
	activar()
	_esperando_fisica = false


func desactivar() -> void:
	super()
	process_mode = Node.PROCESS_MODE_DISABLED


func _physics_process(delta: float) -> void:
	_restante -= delta
	if _restante <= 0.0:
		termino.emit(self)
		return
	super(delta)
