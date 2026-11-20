extends CanvasLayer

signal comenzar

@export var params: RondaParams
@export var cartas: Cartas
@export var plata: Plata
@export var escena_carta: PackedScene
@export var marcos: Array[Texture2D] = []
@export_range(1, 5, 1) var cartas_ofrecidas := 3
@export_range(0, 400, 1, "suffix:px") var espacio_sin_cartas := 218.0
@export_range(0, 400, 1, "suffix:px") var espacio_con_cartas := 44.0
@export_range(0, 400, 1, "suffix:px") var espacio_aviso := 120.0
@export_range(0, 400, 1, "suffix:px") var bajada_aviso := 112.0
@export_range(0, 1, 0.05, "suffix:s") var duracion_entrada := 0.2
@export_range(0, 1, 0.05) var alpha_bloqueado := 0.35
@export var precio_cambio := 100
@export var aumento_cambio := 50

var _bloqueado := false
var _elegida: CartaBoton
var _ofrecidas: Array[Carta] = []
var _cambios := 0
var _foco_previo: Control

@onready var _contenido: Control = $Contenido
@onready var _espacio_arriba: Control = $Contenido/Opciones/EspacioArriba
@onready var _titulo: Label = $Contenido/Opciones/Titulo
@onready var _detalle: Label = $Contenido/Opciones/Detalle
@onready var _espacio: Control = $Contenido/Opciones/Espacio
@onready var _aviso: Control = $Contenido/Opciones/Aviso
@onready var _fila_cartas: HBoxContainer = $Contenido/Opciones/Cartas
@onready var _espacio_cartas: Control = $Contenido/Opciones/EspacioCartas
@onready var _cambiar: BotonPrecio = $Contenido/Opciones/Cambiar
@onready var _espacio_cambiar: Control = $Contenido/Opciones/EspacioCambiar
@onready var _comenzar: Button = $Contenido/Opciones/Comenzar


func _ready() -> void:
	_comenzar.pressed.connect(_on_comenzar_pressed)
	_cambiar.pressed.connect(_on_cambiar_pressed)
	_cambiar.focus_neighbor_left = _cambiar.get_path_to(_cambiar)
	_cambiar.focus_neighbor_right = _cambiar.get_path_to(_cambiar)
	_precalentar.call_deferred()


func _precalentar() -> void:
	var muestra: Array[Carta] = []
	muestra.assign(cartas.pozo.slice(0, cartas_ofrecidas))
	_llenar(1, params.cantidad_rondas, muestra)
	if _fila_cartas.get_child_count() > 0:
		_fila_cartas.get_child(0).elegida = true
	_habilitar_comenzar(true)
	_contenido.modulate.a = 0.01
	visible = true
	for i in 2:
		await get_tree().process_frame
	visible = false
	_armar_cartas([])


func _input(_event: InputEvent) -> void:
	if _bloqueado:
		get_viewport().set_input_as_handled()


func mostrar(numero: int, total: int) -> void:
	_cambios = 0
	_ofrecidas = cartas.ofrecer(cartas_ofrecidas)
	_llenar(numero, total, _ofrecidas)
	_habilitar_comenzar(_ofrecidas.is_empty())
	visible = true
	_contenido.modulate.a = 0.0
	create_tween().tween_property(_contenido, "modulate:a", 1.0, duracion_entrada)
	_bloquear()


func _llenar(numero: int, total: int, ofrecidas: Array[Carta]) -> void:
	var quedan := total - numero
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
	_actualizar_cambiar()


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
	_fila_cartas.visible = not ofrecidas.is_empty()


func _elegir(boton: CartaBoton) -> void:
	if _elegida:
		_elegida.elegida = false
	_elegida = boton
	boton.elegida = true
	_habilitar_comenzar(true)
	_comenzar.grab_focus()


func _habilitar_comenzar(habilitado: bool) -> void:
	_comenzar.disabled = not habilitado
	_comenzar.focus_mode = Control.FOCUS_ALL if habilitado else Control.FOCUS_NONE
	_comenzar.mouse_filter = Control.MOUSE_FILTER_STOP if habilitado else Control.MOUSE_FILTER_IGNORE
	_comenzar.modulate.a = 1.0 if habilitado else 0.0
	_conectar_foco()


func _actualizar_cambiar() -> void:
	var se_puede := _fila_cartas.visible and cartas.quedan() > cartas_ofrecidas
	_cambiar.visible = se_puede
	_espacio_cambiar.visible = se_puede
	if se_puede:
		_cambiar.mostrar_precio(_precio_actual(), plata.alcanza(_precio_actual()))
	_conectar_foco()


func _precio_actual() -> int:
	return precio_cambio + aumento_cambio * _cambios


func _conectar_foco() -> void:
	if _fila_cartas.get_child_count() == 0:
		_comenzar.focus_neighbor_top = NodePath()
		return
	var usable := _cambiar.visible and not _cambiar.disabled
	var carta: Control = _elegida if _elegida else _fila_cartas.get_child(0)
	for boton: Control in _fila_cartas.get_children():
		boton.focus_neighbor_top = boton.get_path_to(_cambiar if usable else boton)
		boton.focus_neighbor_bottom = boton.get_path_to(_comenzar if not _comenzar.disabled else boton)
	_cambiar.focus_neighbor_top = _cambiar.get_path_to(_cambiar)
	_cambiar.focus_neighbor_bottom = _cambiar.get_path_to(carta)
	_comenzar.focus_neighbor_top = _comenzar.get_path_to(carta)


func _on_cambiar_pressed() -> void:
	if not plata.gastar(_precio_actual()):
		return
	_cambios += 1
	_ofrecidas = cartas.ofrecer(cartas_ofrecidas, _ofrecidas)
	_armar_cartas(_ofrecidas)
	_habilitar_comenzar(false)
	_actualizar_cambiar()
	if _cambiar.disabled:
		_fila_cartas.get_child(0).grab_focus()


func _primero() -> Control:
	return _fila_cartas.get_child(0) if _fila_cartas.get_child_count() > 0 else _comenzar


func _on_menu_partida_pauso() -> void:
	if not visible:
		return
	_foco_previo = get_viewport().gui_get_focus_owner()
	_contenido.visible = false


func _on_menu_partida_volvio_a_cartas() -> void:
	_contenido.visible = true
	var foco := _foco_previo if is_instance_valid(_foco_previo) and _foco_previo.is_visible_in_tree() else _primero()
	foco.grab_focus()


func _bloquear() -> void:
	var primero := _primero()
	var atenuado: CanvasItem = _comenzar
	if primero != _comenzar:
		atenuado = _fila_cartas
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
