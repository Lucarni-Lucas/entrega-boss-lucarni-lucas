extends Button
class_name BotonPrecio

@export var color_foco := Color(1.0, 0.88, 0.54)
@export var color_inactivo := Color(0.78, 0.7, 0.48)
@export var color_sin_plata := Color(0.6, 0.6, 0.6)
@export_range(0, 1, 0.05) var alpha_sin_plata := 0.5

@onready var _fila: HBoxContainer = $Fila
@onready var _texto: Label = $Fila/Texto
@onready var _precio: Label = $Fila/Precio


func _ready() -> void:
	focus_entered.connect(_actualizar_estilo)
	focus_exited.connect(_actualizar_estilo)
	mouse_entered.connect(_al_entrar_mouse)
	_actualizar_estilo()


func mostrar_precio(precio: int, alcanza: bool) -> void:
	_precio.text = str(precio)
	custom_minimum_size = _fila.get_combined_minimum_size()
	disabled = not alcanza
	focus_mode = FOCUS_ALL if alcanza else FOCUS_NONE
	modulate.a = 1.0 if alcanza else alpha_sin_plata
	_actualizar_estilo()


func _al_entrar_mouse() -> void:
	if focus_mode != FOCUS_NONE:
		grab_focus()


func _actualizar_estilo() -> void:
	var color := color_sin_plata if disabled else color_foco if has_focus() else color_inactivo
	for etiqueta: Label in [_texto, _precio]:
		etiqueta.add_theme_color_override("font_color", color)
		if has_focus():
			etiqueta.remove_theme_color_override("font_shadow_color")
		else:
			etiqueta.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
