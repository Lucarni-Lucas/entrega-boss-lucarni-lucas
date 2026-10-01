extends CanvasLayer

@export_range(0, 1, 0.05, "suffix:s") var duracion_progreso := 0.3

var _progreso_mostrado := 0.0
var _tween_progreso: Tween

@onready var _tiempo: Label = $Tiempo
@onready var _resultado: Label = $Resultado
@onready var _vida: ProgressBar = $Vida
@onready var _vida_texto: Label = $Vida/Texto
@onready var _progreso_curacion: ProgressBar = $ProgresoCuracion


func _on_partida_tiempo_cambio(restante: float) -> void:
	var segundos := ceili(restante)
	@warning_ignore("integer_division")
	_tiempo.text = "%d:%02d" % [segundos / 60, segundos % 60]


func _on_partida_finalizo(gano: bool) -> void:
	_resultado.text = "¡YOU WON!" if gano else "YOU DIED"
	_resultado.visible = true


func _on_player_vida_cambio(actual: int, maximo: int) -> void:
	_vida.max_value = maximo
	_vida.value = actual
	_vida_texto.text = "%d / %d" % [actual, maximo]


func _on_curacion_por_muertes_progreso_cambio(progreso: float) -> void:
	if _tween_progreso:
		_tween_progreso.kill()
	_tween_progreso = create_tween()
	_tween_progreso.tween_method(_mostrar_progreso, _progreso_mostrado, progreso, duracion_progreso).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func _mostrar_progreso(progreso: float) -> void:
	_progreso_mostrado = progreso
	_progreso_curacion.value = fposmod(progreso, 1.0)
