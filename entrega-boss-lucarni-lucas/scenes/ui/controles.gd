extends Control

signal cerrado

const _ICONO := preload("res://scenes/ui/icono_tecla.tscn")
const _NOMBRES := ["Teclado y mouse", "Teclado", "Joystick"]
const _TECLADO := 1
const _FILAS := [
	["Moverse", "mover"],
	["Saltar", "saltar"],
	["Ground pound", "ground_pound"],
	["Slash", "slash"],
	["Dive", "dive"],
	["Boomerang", "boomerang"],
	["Pausa", "pausa"],
]

@export var color_punto_inactivo := Color(0.4, 0.4, 0.4)

var _pagina := _TECLADO

@onready var _recomendado: Label = $Contenido/Recomendado
@onready var _nombre: Label = $Contenido/Selector/Nombre
@onready var _izquierda: Button = $Contenido/Selector/Izquierda
@onready var _derecha: Button = $Contenido/Selector/Derecha
@onready var _puntos := $Contenido/Puntos.get_children()
@onready var _paginas := $Contenido/Paginas.get_children()
@onready var _boton: Button = $Contenido/Boton
@onready var _modelo_nombre: Label = $Modelos/Nombre
@onready var _modelo_teclas: HBoxContainer = $Modelos/Teclas
@onready var _modelo_separador: Label = $Modelos/Separador


func _ready() -> void:
	_izquierda.pressed.connect(_cambiar_pagina.bind(-1))
	_derecha.pressed.connect(_cambiar_pagina.bind(1))
	_boton.pressed.connect(_cerrar)
	_armar_paginas()


func abrir() -> void:
	_pagina = EsquemaInput.actual
	_mostrar_pagina()
	visible = true
	_boton.grab_focus()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("pagina_anterior"):
		_cambiar_pagina(-1)
	elif event.is_action_pressed("pagina_siguiente"):
		_cambiar_pagina(1)
	elif event.is_action_pressed("ui_cancel"):
		_cerrar()
	else:
		return
	get_viewport().set_input_as_handled()


func _cambiar_pagina(direccion: int) -> void:
	var nueva := clampi(_pagina + direccion, 0, _paginas.size() - 1)
	if nueva == _pagina:
		return
	_pagina = nueva
	_mostrar_pagina()
	Audio.tocar(Audio.libreria.ui_foco)


func _mostrar_pagina() -> void:
	_nombre.text = _NOMBRES[_pagina]
	_recomendado.modulate.a = 1.0 if _pagina == _TECLADO else 0.0
	_mostrar_flecha(_izquierda, _pagina > 0)
	_mostrar_flecha(_derecha, _pagina < _paginas.size() - 1)
	for i in _paginas.size():
		_paginas[i].visible = i == _pagina
		_puntos[i].modulate = Color.WHITE if i == _pagina else color_punto_inactivo


func _mostrar_flecha(flecha: Button, disponible: bool) -> void:
	flecha.disabled = not disponible
	flecha.modulate.a = 1.0 if disponible else 0.0


func _cerrar() -> void:
	visible = false
	Audio.tocar(Audio.libreria.ui_volver)
	cerrado.emit()


func _armar_paginas() -> void:
	for esquema in _paginas.size():
		for fila in _FILAS:
			var nombre: Label = _modelo_nombre.duplicate()
			nombre.text = fila[0]
			_paginas[esquema].add_child(nombre)
			_paginas[esquema].add_child(_crear_teclas(fila[1], esquema))
	_igualar_filas()


func _igualar_filas() -> void:
	var celdas: Array[Control] = []
	for pagina: Control in _paginas:
		celdas.append_array(pagina.get_children())
	var alto := 0.0
	for celda in celdas:
		alto = maxf(alto, celda.get_combined_minimum_size().y)
	for celda in celdas:
		celda.custom_minimum_size.y = alto


func _crear_teclas(accion: String, esquema: EsquemaInput.Esquema) -> HBoxContainer:
	var teclas: HBoxContainer = _modelo_teclas.duplicate()
	var texturas := EsquemaInput.teclas(accion, esquema)
	for i in texturas.size():
		if i > 0 and accion == "pausa":
			teclas.add_child(_modelo_separador.duplicate())
		var icono: IconoTecla = _ICONO.instantiate()
		icono.textura = texturas[i]
		icono.accion = _accion_de_tecla(accion, i, texturas.size())
		icono.esquema = esquema
		teclas.add_child(icono)
	return teclas


func _accion_de_tecla(accion: String, indice: int, cantidad: int) -> StringName:
	if accion == "pausa":
		return &""
	if accion == "mover":
		return EsquemaInput.DIRECCIONES[indice] if cantidad == EsquemaInput.DIRECCIONES.size() else &""
	return accion
