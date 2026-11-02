extends Node

signal salto

var _buffer := BufferVerbo.new(&"saltar")


func procesar_fisica(player: Player, delta: float) -> void:
	## Por encima de esa altura la tecla compartida es ground pound, no salto.
	var pedido := _buffer.actualizar(delta, player.params.salto_buffer, player.z < player.params.gp_altura_minima)

	if pedido and player.estado_actual() == Player.Estado.EN_SUELO:
		_buffer.consumir()
		player.aplicar_impulso_vertical(player.params.fuerza_salto)
		salto.emit()


func descartar_buffer() -> void:
	_buffer.consumir()
