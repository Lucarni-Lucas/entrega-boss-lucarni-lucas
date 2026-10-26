extends CanvasLayer

signal comenzar

@export var params: RondaParams
@export var cartas: Cartas
@export var escena_carta: PackedScene
@export var marcos: Array[Texture2D] = []
@export_range(1, 5, 1) var cartas_ofrecidas := 3
@export_range(0, 400, 1, "suffix:px") var espacio_sin_cartas := 218.0
@export_range(0, 400, 1, "suffix:px") var espacio_con_cartas := 44.0
@export_range(0, 400, 1, "suffix:px") var espacio_aviso := 120.0
@export_range(0, 400, 1, "suffix:px") var bajada_aviso := 112.0
@export_range(0, 1, 0.05, "suffix:s") var duracion_entrada := 0.2
@export_range(0, 1, 0.05) var alpha_bloqueado := 0.35

var _bloqueado := false
var _elegida: CartaBoton

@onready var _contenido: Control = $Contenido
@onready var _espacio_arriba: Control = $Contenido/Opciones/EspacioArriba
@onready var _titulo: Label = $Contenido/Opciones/Titulo
@onready var _detalle: Label = $Contenido/Opciones/Detalle
@onready var _espacio: Control = $Contenido/Opciones/Espacio
@onready var _aviso: Control = $Contenido/Opciones/Aviso
@onready var _fila_cartas: HBoxContainer = $Contenido/Opciones/Cartas
@onready var _espacio_cartas: Control = $Contenido/Opciones/EspacioCartas
@onready var _comenzar: Button = $Contenido/Opciones/Comenzar


func _ready() -> void:
	_comenzar.pressed.connect(_on_comenzar_pressed)


func _input(_event: InputEvent) -> void:
	if _bloqueado:
		get_viewport().set_input_as_handled()


func mostrar(numero: int, total: int) -> void:
	var quedan := total - numero
	var ofrecidas := cartas.ofrecer(cartas_ofrecidas)
	var hay_cartas := not ofrecidas.is_empty()
	var todas_tomadas := not hay_cartas and not cartas.pozo.is_empty()
	_titulo.text = "¡RONDA %d COMPLETA!" % numero
	_detalle.text = "Te queda 1 ronda" if quedan == 1 else "Te quedan %d rondas" % quedan
	if hay_cartas:
		_detalle.text += " · Elegí una carta, te dura toda la partida"
	_comenzar.poner_texto("Comenzar ronda %d" % (numero + 1))
	_armar_cartas(ofrecidas)
	_aviso.visible = todas_tomadas
	_espacio_arriba.custom_minimum_size.y = bajada_aviso if todas_tomadas else 0.0
	_espacio.custom_minimum_size.y = espacio_con_cartas if hay_cartas else espacio_aviso if todas_tomadas else espacio_sin_cartas
	_espacio_cartas.custom_minimum_size.y = espacio_aviso if todas_tomadas else espacio_con_cartas
	_espacio_cartas.visible = hay_cartas or todas_tomadas
	_habilitar_comenzar(not hay_cartas)
	visible = true
	_contenido.modulate.a = 0.0
	create_tween().tween_property(_contenido, "modulate:a", 1.0, duracion_entrada)
	_bloquear()


func _armar_cartas(ofrecidas: Array[Carta]) -> void:
	_elegida = null
	for hijo in _fila_cartas.get_children():
		_fila_cartas.remove_child(hijo)
		hijo.queue_free()
	var botones: Array[CartaBoton] = []
	for i in ofrecidas.size():
		var boton: CartaBoton = escena_carta.instantiate()
		_fila_cartas.add_child(boton)
		boton.mostrar(ofrecidas[i], marcos[i % marcos.size()])
		boton.pressed.connect(_elegir.bind(boton))
		botones.append(boton)
	for i in botones.size():
		var boton := botones[i]
		boton.focus_neighbor_left = boton.get_path_to(botones[maxi(i - 1, 0)])
		boton.focus_neighbor_right = boton.get_path_to(botones[mini(i + 1, botones.size() - 1)])
		boton.focus_neighbor_top = boton.get_path_to(boton)
		boton.focus_neighbor_bottom = boton.get_path_to(_comenzar)
	_fila_cartas.visible = not ofrecidas.is_empty()


func _elegir(boton: CartaBoton) -> void:
	if _elegida:
		_elegida.elegida = false
	_elegida = boton
	boton.elegida = true
	_comenzar.focus_neighbor_top = _comenzar.get_path_to(boton)
	_habilitar_comenzar(true)


func _habilitar_comenzar(habilitado: bool) -> void:
	_comenzar.disabled = not habilitado
	_comenzar.focus_mode = Control.FOCUS_ALL if habilitado else Control.FOCUS_NONE
	_comenzar.mouse_filter = Control.MOUSE_FILTER_STOP if habilitado else Control.MOUSE_FILTER_IGNORE
	_comenzar.modulate.a = 1.0 if habilitado else 0.0


func _bloquear() -> void:
	var primero: Control = _fila_cartas.get_child(0) if _fila_cartas.get_child_count() > 0 else _comenzar
	var atenuado: CanvasItem = _fila_cartas if primero != _comenzar else _comenzar
	_bloqueado = true
	atenuado.modulate.a = alpha_bloqueado
	await get_tree().create_timer(params.bloqueo_final).timeout
	_bloqueado = false
	atenuado.modulate.a = 1.0
	primero.grab_focus()


func _on_comenzar_pressed() -> void:
	if _elegida:
		cartas.aplicar(_elegida.carta)
	visible = false
	comenzar.emit()
