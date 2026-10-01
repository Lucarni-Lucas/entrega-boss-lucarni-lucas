extends CanvasLayer

@onready var _tiempo: Label = $Tiempo
@onready var _resultado: Label = $Resultado


func _on_partida_tiempo_cambio(restante: float) -> void:
	var segundos := ceili(restante)
	@warning_ignore("integer_division")
	_tiempo.text = "%d:%02d" % [segundos / 60, segundos % 60]


func _on_partida_finalizo(gano: bool) -> void:
	_resultado.text = "¡YOU WON!" if gano else "YOU DIED"
	_resultado.visible = true
