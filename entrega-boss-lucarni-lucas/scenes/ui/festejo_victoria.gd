extends CanvasLayer

@export_range(0.5, 5, 0.1, "suffix:s") var cada_festejo := 1.6

@onready var _boomie: Boomie = $Contenido/Boomie
@onready var _confetis: Array[CPUParticles2D] = [$Contenido/ConfetiIzquierda, $Contenido/ConfetiDerecha]


func _ready() -> void:
	visible = false


func _on_partida_finalizo(gano: bool) -> void:
	if not gano:
		return
	visible = true
	_boomie.entrar(true)
	for confeti in _confetis:
		confeti.restart()
	var festejos := create_tween().set_loops()
	festejos.tween_interval(cada_festejo)
	festejos.tween_callback(_boomie.festejar)
