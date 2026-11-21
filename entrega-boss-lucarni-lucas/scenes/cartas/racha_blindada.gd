extends EfectoCarta


func _ready() -> void:
	jugador.combo_subio.connect(_on_combo_subio)
	jugador.golpe_blindado.connect(_on_golpe_blindado)


func _on_combo_subio(combo: int) -> void:
	if combo % jugador.params.blindaje_cada_combo != 0:
		return
	var antes := jugador.blindaje
	jugador.blindar(jugador.params.blindaje_por_racha)
	if jugador.blindaje > antes:
		Audio.tocar(Audio.libreria.blindaje_ganado)


func _on_golpe_blindado() -> void:
	Audio.tocar(Audio.libreria.blindaje_gastado)
