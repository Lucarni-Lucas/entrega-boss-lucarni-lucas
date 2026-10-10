extends Control

signal cerrado

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
@onready var _modelo_tecla: Label = $Modelos/Tecla
@onready var _modelo_icono: TextureRect = $Modelos/Icono


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
	_pagina = clampi(_pagina + direccion, 0, _paginas.size() - 1)
	_mostrar_pagina()


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
	cerrado.emit()


func _armar_paginas() -> void:
	for esquema in _paginas.size():
		for fila in _FILAS:
			var nombre: Label = _modelo_nombre.duplicate()
			nombre.text = fila[0]
			_paginas[esquema].add_child(nombre)
			_paginas[esquema].add_child(_crear_tecla(EsquemaInput.TECLAS[fila[1]][esquema]))


func _crear_tecla(tecla: Variant) -> Control:
	if tecla is Texture2D:
		var icono: TextureRect = _modelo_icono.duplicate()
		icono.texture = tecla
		return icono
	var etiqueta: Label = _modelo_tecla.duplicate()
	etiqueta.text = tecla
	return etiqueta
