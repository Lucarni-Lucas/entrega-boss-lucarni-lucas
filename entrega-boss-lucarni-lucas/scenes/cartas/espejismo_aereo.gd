extends EfectoCarta

const _SHADER := preload("res://scenes/cartas/espejismo_aereo.gdshader")

@export var escena_boomerang: PackedScene
@export var color_brillos := Color(0.55, 0.78, 1.0)

var copia: Boomerang


func _ready() -> void:
	copia = escena_boomerang.instantiate()
	copia.vuelve = false
	copia.giro = -copia.giro
	jugador.lanzo_boomerang.connect(_on_lanzo_boomerang)
	jugador.aterrizo.connect(copia.desvanecer)
	jugador.volvio_al_inicio.connect(copia.cancelar)
	jugador.boomie_electrizado.connect(_on_boomie_electrizado)
	_agregar_copia.call_deferred()


func _agregar_copia() -> void:
	jugador.agregar_al_mundo(copia)
	var material := ShaderMaterial.new()
	material.shader = _SHADER
	copia.get_node("Sprite/Visual").material = material
	for nombre in ["Destello", "Destello2", "Chispas"]:
		copia.get_node("Sprite/" + nombre).self_modulate = color_brillos
	copia.electrizado = jugador.boomie_cargado_de_electricidad
	copia.cancelar()


func _on_lanzo_boomerang() -> void:
	copia.lanzar(jugador, -jugador.ultima_direccion)


func _on_boomie_electrizado(activo: bool) -> void:
	copia.electrizado = activo
