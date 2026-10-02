extends Button

@export var color_inactivo := Color(0.6, 0.6, 0.6)

@onready var _etiqueta: Label = $Texto


func _ready() -> void:
	_etiqueta.text = text
	text = ""
	custom_minimum_size = _etiqueta.get_minimum_size()
	focus_entered.connect(_actualizar_estilo)
	focus_exited.connect(_actualizar_estilo)
	mouse_entered.connect(grab_focus)
	_actualizar_estilo()


func _actualizar_estilo() -> void:
	if has_focus():
		_etiqueta.remove_theme_color_override("font_color")
		_etiqueta.remove_theme_color_override("font_shadow_color")
	else:
		_etiqueta.add_theme_color_override("font_color", color_inactivo)
		_etiqueta.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
