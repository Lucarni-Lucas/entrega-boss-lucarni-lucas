extends CanvasLayer

@onready var _tiempo: Label = $Tiempo
@onready var _vida := $Vida
@onready var _numero: Label = $Numero/Texto


func _on_partida_tiempo_cambio(restante: float) -> void:
	var segundos := ceili(restante)
	@warning_ignore("integer_division")
	_tiempo.text = "%d:%02d" % [segundos / 60, segundos % 60]


func _on_player_vida_cambio(actual: int, maximo: int) -> void:
	_vida.mostrar(actual, maximo)
	_numero.text = str(actual)
