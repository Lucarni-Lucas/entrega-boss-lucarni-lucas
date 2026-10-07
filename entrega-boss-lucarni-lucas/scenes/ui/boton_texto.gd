extends Button

@export var color_inactivo := Color(0.6, 0.6, 0.6)

@onready var _etiqueta: Label = $Texto


func _ready() -> void:
	poner_texto(text)
	text = ""
	focus_entered.connect(_actualizar_estilo)
	focus_exited.connect(_actualizar_estilo)
	if focus_mode != FOCUS_NONE:
		mouse_entered.connect(grab_focus)
	_actualizar_estilo()


func poner_texto(nuevo: String) -> void:
	_etiqueta.text = nuevo
	custom_minimum_size = _etiqueta.get_minimum_size()


func _actualizar_estilo() -> void:
	if has_focus() or focus_mode == FOCUS_NONE:
		_etiqueta.remove_theme_color_override("font_color")
		_etiqueta.remove_theme_color_override("font_shadow_color")
	else:
		_etiqueta.add_theme_color_override("font_color", color_inactivo)
		_etiqueta.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)


func _gui_input(event: InputEvent) -> void:
	if event.is_action("ui_left") or event.is_action("ui_right"):
		accept_event()
