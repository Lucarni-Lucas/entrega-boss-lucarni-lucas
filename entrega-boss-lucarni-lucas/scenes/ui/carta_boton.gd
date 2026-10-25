extends Button
class_name CartaBoton

@export var color_apagado := Color(0.55, 0.55, 0.55)

var carta: Carta
var elegida := false:
	set(valor):
		elegida = valor
		_actualizar_estilo()

@onready var _halo: Control = $Halo
@onready var _marco: TextureRect = $Marco
@onready var _nombre: Label = $Nombre
@onready var _icono: TextureRect = $Icono
@onready var _descripcion: Label = $Descripcion


func _ready() -> void:
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
	elegida = false


func _actualizar_estilo() -> void:
	if not is_node_ready():
		return
	modulate = Color.WHITE if has_focus() or elegida else color_apagado
	_halo.visible = elegida
