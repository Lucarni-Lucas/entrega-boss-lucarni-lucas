extends Button
class_name CartaBoton

@export var color_apagado := Color(0.55, 0.55, 0.55)
@export var tamano_minimo_descripcion := 18

var carta: Carta
var elegida := false:
	set(valor):
		elegida = valor
		_actualizar_estilo()
var _tamano_descripcion: int
var _alto_descripcion: float

@onready var _halo: Control = $Halo
@onready var _marco: TextureRect = $Marco
@onready var _nombre: Label = $Nombre
@onready var _icono: TextureRect = $Icono
@onready var _descripcion: Label = $Descripcion


func _ready() -> void:
	_tamano_descripcion = _descripcion.get_theme_font_size(&"font_size")
	_alto_descripcion = _descripcion.offset_bottom - _descripcion.offset_top
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
	var tamano := _tamano_descripcion
	_descripcion.add_theme_font_size_override(&"font_size", tamano)
	while tamano > tamano_minimo_descripcion and _descripcion.get_minimum_size().y > _alto_descripcion:
		tamano -= 1
		_descripcion.add_theme_font_size_override(&"font_size", tamano)


func _actualizar_estilo() -> void:
	if not is_node_ready():
		return
	modulate = Color.WHITE if has_focus() or elegida else color_apagado
	_halo.visible = elegida
