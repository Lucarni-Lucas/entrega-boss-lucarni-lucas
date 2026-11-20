extends Button
class_name CartaBoton

@export var color_apagado := Color(0.55, 0.55, 0.55)
@export var tamano_minimo_descripcion := 18
@export var renglones_descripcion := 4

var carta: Carta
var elegida := false:
	set(valor):
		elegida = valor
		_actualizar_estilo()
var _tamano_descripcion: int
var _centro_descripcion: float
var _ancho_descripcion: float

@onready var _halo: Control = $Halo
@onready var _marco: TextureRect = $Marco
@onready var _nombre: Label = $Nombre
@onready var _icono: TextureRect = $Icono
@onready var _descripcion: Label = $Descripcion


func _ready() -> void:
	_tamano_descripcion = _descripcion.get_theme_font_size(&"font_size")
	_centro_descripcion = (_descripcion.offset_left + _descripcion.offset_right) * 0.5
	_ancho_descripcion = _descripcion.offset_right - _descripcion.offset_left
	focus_entered.connect(_actualizar_estilo)
	focus_exited.connect(_actualizar_estilo)
	mouse_entered.connect(grab_focus)
	_actualizar_estilo()


func mostrar(nueva: Carta, marco: Texture2D) -> void:
	carta = nueva
	_marco.texture = marco
	_nombre.text = carta.nombre
	_icono.texture = carta.icono
	_descripcion.text = carta.descripcion
	_ajustar_descripcion()
	elegida = false


func _ajustar_descripcion() -> void:
	var fuente := _descripcion.get_theme_font(&"font")
	var margen := _descripcion.get_theme_stylebox(&"normal").get_minimum_size().x
	var disponible := _ancho_descripcion - margen
	var tamano := _tamano_descripcion
	while tamano > tamano_minimo_descripcion and _renglones(fuente, tamano, disponible) > renglones_descripcion:
		tamano -= 1
	_descripcion.add_theme_font_size_override(&"font_size", tamano)
	var angosto := 1.0
	var ancho := disponible
	for i in 20:
		var medio := (angosto + ancho) * 0.5
		if _renglones(fuente, tamano, medio) <= renglones_descripcion:
			ancho = medio
		else:
			angosto = medio
	ancho = minf(ceilf(ancho) + 1.0, disponible) + margen
	_descripcion.offset_left = _centro_descripcion - ancho * 0.5
	_descripcion.offset_right = _centro_descripcion + ancho * 0.5


func _renglones(fuente: Font, tamano: int, ancho: float) -> int:
	var parrafo := TextParagraph.new()
	parrafo.break_flags = TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND | TextServer.BREAK_ADAPTIVE
	parrafo.add_string(_descripcion.text, fuente, tamano)
	parrafo.width = ancho
	return parrafo.get_line_count()


func _actualizar_estilo() -> void:
	if not is_node_ready():
		return
	modulate = Color.WHITE if has_focus() or elegida else color_apagado
	_halo.visible = elegida
