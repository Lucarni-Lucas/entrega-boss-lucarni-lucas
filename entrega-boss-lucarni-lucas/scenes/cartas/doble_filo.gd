extends EfectoCarta


func _ready() -> void:
	jugador.lanzo_boomerang.connect(jugador.slash_circular)
	jugador.atrapo_boomerang.connect(jugador.slash_circular)
