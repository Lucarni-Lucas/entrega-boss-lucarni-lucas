extends HSlider

@export var tramos := 10
@export_range(0, 40, 1, "suffix:px") var separacion := 8.0
@export_range(0, 40, 1, "suffix:px") var inclinacion := 10.0
@export_range(0, 20, 1, "suffix:px") var margen_fondo := 6.0
@export var color_fondo := Color(0.08, 0.08, 0.094, 0.85)
@export var color_vacio := Color("2c2c33")
@export var color_lleno := Color("f5f2e3")
@export var color_lleno_inactivo := Color("8a877f")


func _ready() -> void:
	var vacio := StyleBoxEmpty.new()
	for estilo in [&"slider", &"grabber_area", &"grabber_area_highlight", &"focus"]:
		add_theme_stylebox_override(estilo, vacio)
	var sin_icono := ImageTexture.create_from_image(Image.create(1, 1, false, Image.FORMAT_RGBA8))
	for icono in [&"grabber", &"grabber_highlight", &"grabber_disabled", &"tick"]:
		add_theme_icon_override(icono, sin_icono)
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)


func _draw() -> void:
	var llenos := roundi((value - min_value) / (max_value - min_value) * tramos)
	var ancho_tramo := (size.x - inclinacion - separacion * (tramos - 1)) / tramos
	_paralelogramo(Vector2(inclinacion - margen_fondo, -margen_fondo), size.x - inclinacion + margen_fondo * 2, size.y + margen_fondo * 2, color_fondo)
	for tramo in tramos:
		var color := color_vacio
		if tramo < llenos:
			color = color_lleno if has_focus() else color_lleno_inactivo
		_paralelogramo(Vector2(inclinacion + tramo * (ancho_tramo + separacion), 0), ancho_tramo, size.y, color)


func _paralelogramo(origen: Vector2, ancho: float, alto: float, color: Color) -> void:
	var corrimiento := inclinacion * alto / size.y
	var puntos := PackedVector2Array([origen, origen + Vector2(ancho, 0), origen + Vector2(ancho - corrimiento, alto), origen + Vector2(-corrimiento, alto)])
	draw_colored_polygon(puntos, color)
	puntos.append(origen)
	draw_polyline(puntos, color, 1.0, true)
