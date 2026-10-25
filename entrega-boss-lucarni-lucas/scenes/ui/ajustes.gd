extends Control

signal cerrado

const _FILAS := [["General", &"Master"], ["Efectos", &"Efectos"], ["Interfaz", &"UI"], ["Música", &"Musica"]]

@export var color_inactivo := Color(0.6, 0.6, 0.6)

var _nombres: Array[Label] = []
var _barras: Array[HSlider] = []
var _valores: Array[Label] = []

@onready var _grilla: GridContainer = $Contenido/Grilla
@onready var _boton: Button = $Contenido/Boton
@onready var _modelo_nombre: Label = $Modelos/Nombre
@onready var _modelo_barra: HSlider = $Modelos/Barra
@onready var _modelo_valor: Label = $Modelos/Valor


func _ready() -> void:
	_boton.pressed.connect(_cerrar)
	_modelo_valor.text = "100 %"
	_modelo_valor.custom_minimum_size.x = _modelo_valor.get_minimum_size().x
	for i in _FILAS.size():
		var nombre: Label = _modelo_nombre.duplicate()
		nombre.text = _FILAS[i][0]
		var barra: HSlider = _modelo_barra.duplicate()
		barra.value_changed.connect(_on_barra_cambio.bind(i))
		barra.focus_entered.connect(_marcar_fila.bind(i, true))
		barra.focus_exited.connect(_marcar_fila.bind(i, false))
		var valor: Label = _modelo_valor.duplicate()
		_grilla.add_child(nombre)
		_grilla.add_child(barra)
		_grilla.add_child(valor)
		_nombres.append(nombre)
		_barras.append(barra)
		_valores.append(valor)
		_marcar_fila(i, false)


func abrir() -> void:
	for i in _FILAS.size():
		var porcentaje := roundf(Audio.volumen_bus(_FILAS[i][1]) * 100.0)
		_barras[i].set_value_no_signal(porcentaje)
		_barras[i].queue_redraw()
		_valores[i].text = "%d %%" % porcentaje
	visible = true
	_barras[0].grab_focus()


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_cerrar()
		get_viewport().set_input_as_handled()


func _on_barra_cambio(porcentaje: float, indice: int) -> void:
	var bus: StringName = _FILAS[indice][1]
	Audio.poner_volumen_bus(bus, porcentaje / 100.0)
	_valores[indice].text = "%d %%" % porcentaje
	if bus == &"Efectos":
		Audio.tocar(Audio.libreria.dive)
	elif bus != &"Musica":
		Audio.tocar(Audio.libreria.ui_foco)


func _marcar_fila(indice: int, elegida: bool) -> void:
	var color := Color.WHITE if elegida else color_inactivo
	_nombres[indice].modulate = color
	_valores[indice].modulate = color


func _cerrar() -> void:
	visible = false
	Audio.guardar_volumenes()
	Audio.tocar(Audio.libreria.ui_volver)
	cerrado.emit()
