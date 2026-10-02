extends Control

signal empezar
signal cerrado

const _NOMBRES := ["Teclado y mouse", "Teclado", "Joystick"]
const _TECLADO := 1

@export var color_punto_inactivo := Color(0.4, 0.4, 0.4)

var _pagina := _TECLADO
var _antes_de_jugar := false

@onready var _recomendado: Label = $Contenido/Recomendado
@onready var _nombre: Label = $Contenido/Selector/Nombre
@onready var _izquierda: Button = $Contenido/Selector/Izquierda
@onready var _derecha: Button = $Contenido/Selector/Derecha
@onready var _puntos := $Contenido/Puntos.get_children()
@onready var _paginas := $Contenido/Paginas.get_children()
@onready var _boton: Button = $Contenido/Boton


func _ready() -> void:
	_izquierda.pressed.connect(_cambiar_pagina.bind(-1))
	_derecha.pressed.connect(_cambiar_pagina.bind(1))
	_boton.pressed.connect(_on_boton_pressed)


func abrir(antes_de_jugar: bool) -> void:
	_antes_de_jugar = antes_de_jugar
	_boton.poner_texto("Empezar" if antes_de_jugar else "Volver")
	_pagina = _TECLADO
	_mostrar_pagina()
	visible = true
	_boton.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_left"):
		_cambiar_pagina(-1)
	elif event.is_action_pressed("ui_right"):
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


func _on_boton_pressed() -> void:
	if _antes_de_jugar:
		empezar.emit()
	else:
		_cerrar()


func _cerrar() -> void:
	visible = false
	cerrado.emit()
