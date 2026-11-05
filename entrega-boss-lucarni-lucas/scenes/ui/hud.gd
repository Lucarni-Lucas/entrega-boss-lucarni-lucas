extends CanvasLayer
class_name Hud

@export var con_tiempo := true
@export var con_plata := true

var _segundos := -1

@onready var _tiempo: Label = $Tiempo
@onready var _vida := $Vida
@onready var _numero: Label = $Numero/Texto
@onready var _plata: Control = $Plata
@onready var _texto_plata: Label = $Plata/Fila/Texto


func _ready() -> void:
	_tiempo.visible = con_tiempo
	_plata.visible = con_plata


func _on_partida_tiempo_cambio(restante: float) -> void:
	var segundos := ceili(restante)
	if segundos == _segundos:
		return
	_segundos = segundos
	@warning_ignore("integer_division")
	_tiempo.text = "%d:%02d" % [segundos / 60, segundos % 60]


func _on_player_vida_cambio(actual: int, maximo: int) -> void:
	_vida.mostrar(actual, maximo)
	_numero.text = str(actual)


func _on_player_energia_gp_cambio(actual: float, minima: float, maxima: float) -> void:
	_vida.mostrar_energia(actual / maxima, minima / maxima)


func _on_plata_cambio(cantidad: int) -> void:
	_texto_plata.text = str(cantidad)
	_plata.reset_size.call_deferred()


func resaltar_energia(resaltar: bool) -> void:
	_vida.resaltar_energia = resaltar
