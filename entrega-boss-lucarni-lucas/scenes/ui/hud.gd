extends CanvasLayer
class_name Hud

@export var con_tiempo := true

@onready var _tiempo: Label = $Tiempo
@onready var _vida := $Vida
@onready var _numero: Label = $Numero/Texto


func _ready() -> void:
	_tiempo.visible = con_tiempo


func _on_partida_tiempo_cambio(restante: float) -> void:
	var segundos := ceili(restante)
	@warning_ignore("integer_division")
	_tiempo.text = "%d:%02d" % [segundos / 60, segundos % 60]


func _on_player_vida_cambio(actual: int, maximo: int) -> void:
	_vida.mostrar(actual, maximo)
	_numero.text = str(actual)


func _on_player_energia_gp_cambio(actual: float, minima: float, maxima: float) -> void:
	_vida.mostrar_energia(actual / maxima, minima / maxima)


func resaltar_energia(resaltar: bool) -> void:
	_vida.resaltar_energia = resaltar
