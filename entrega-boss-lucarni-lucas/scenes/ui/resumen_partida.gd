extends Control
class_name ResumenPartida

@export var marcos: Array[Texture2D] = []
@export var estilo_icono: StyleBox
@export var estilo_foco: StyleBox
@export_range(0, 100, 1, "suffix:px") var espacio_carta := 24.0
@export_range(0, 1, 0.05, "suffix:s") var duracion_desliz := 0.15
@export_range(0, 1, 0.05) var asomo := 0.5
@export_group("Cartas")
@export_range(40, 200, 1, "suffix:px") var tamano_icono := 84.0
@export_range(0, 60, 1, "suffix:px") var separacion_iconos := 18.0
@export_range(0, 30, 1, "suffix:px") var margen_iconos := 10.0
@export_group("Rondas")
@export_range(20, 120, 1, "suffix:px") var tamano_numero := 60.0
@export_range(10, 60, 1) var tamano_texto_numero := 30
@export_range(20, 120, 1, "suffix:px") var alto_evento := 64.0
@export_range(0, 40, 1, "suffix:px") var espacio_evento := 8.0
@export_range(0, 200, 1, "suffix:px") var separacion_rondas := 60.0
@export_range(0, 20, 1, "suffix:px") var grosor_linea := 4.0
@export_range(0, 10, 1, "suffix:px") var grosor_borde := 3
@export_range(0, 20, 1, "suffix:px") var separacion_anillo := 7.0
@export var color_pasada := Color(0.36, 0.35, 0.33)
@export var color_actual := Color.WHITE
@export var color_futura := Color(0.54, 0.53, 0.5)
@export var color_fondo_numero := Color(0.15, 0.15, 0.18)
@export var color_texto_oscuro := Color(0.15, 0.15, 0.18)
@export var color_texto_claro := Color(0.95, 0.94, 0.9)
@export_range(0, 1, 0.05) var alpha_evento_pasado := 0.4

var _desplazamiento := 0.0
var _separacion_actual := 0.0
var _tween_iconos: Tween
var _ronda := 0
var _cantidad_rondas := 0

@onready var _ventana_cartas: Control = %VentanaCartas
@onready var _iconos: HBoxContainer = %Iconos
@onready var _vacio: Label = %Vacio
@onready var _ventana_rondas: Control = %VentanaRondas
@onready var _pista: Control = %Pista
@onready var _linea: ColorRect = %Linea
@onready var _numeros: HBoxContainer = %Numeros
@onready var _carta: CartaBoton = %Carta


func _ready() -> void:
	_carta.focus_mode = Control.FOCUS_NONE
	_carta.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ventana_cartas.custom_minimum_size.y = tamano_icono + margen_iconos * 2.0
	_ventana_cartas.resized.connect(_ajustar_iconos)
	_ventana_rondas.resized.connect(_ubicar_rondas)


func mostrar(tomadas: Array[Carta], params: RondaParams, ronda: int) -> void:
	_carta.visible = false
	_armar_iconos(tomadas)
	_armar_rondas(params, ronda)


func iconos() -> Array[Node]:
	return _iconos.get_children()


func _separacion_para(cantidad: int, tamano: float, separacion: float, ancho_visible: float) -> float:
	if cantidad * (tamano + separacion) - separacion <= ancho_visible:
		return separacion
	var util := ancho_visible - tamano * asomo
	var enteros := maxi(floori((util + separacion) / (tamano + separacion)), 1)
	return floorf(util / enteros - tamano)


func _armar_iconos(tomadas: Array[Carta]) -> void:
	for hijo in _iconos.get_children():
		_iconos.remove_child(hijo)
		hijo.queue_free()
	_vacio.visible = tomadas.is_empty()
	_ventana_cartas.visible = not tomadas.is_empty()
	_desplazamiento = 0.0
	if _tween_iconos:
		_tween_iconos.kill()
	_iconos.position = Vector2.ONE * margen_iconos
	for i in tomadas.size():
		var boton := Button.new()
		boton.custom_minimum_size = Vector2.ONE * tamano_icono
		boton.icon = tomadas[i].icono
		boton.expand_icon = true
		boton.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		for estado: StringName in [&"normal", &"hover", &"pressed", &"hover_pressed"]:
			boton.add_theme_stylebox_override(estado, estilo_icono)
		boton.add_theme_stylebox_override(&"focus", estilo_foco)
		boton.focus_entered.connect(_on_icono_enfocado.bind(tomadas[i], i))
		boton.focus_exited.connect(_carta.hide)
		boton.mouse_entered.connect(boton.grab_focus)
		_iconos.add_child(boton)
	var botones := _iconos.get_children()
	for i in botones.size():
		var boton: Control = botones[i]
		boton.focus_neighbor_left = boton.get_path_to(botones[maxi(i - 1, 0)])
		boton.focus_neighbor_right = boton.get_path_to(botones[mini(i + 1, botones.size() - 1)])
		boton.focus_neighbor_bottom = boton.get_path_to(boton)
	_ajustar_iconos()


func _ajustar_iconos() -> void:
	var ancho_visible := _ventana_cartas.size.x - margen_iconos * 2.0
	_separacion_actual = _separacion_para(_iconos.get_child_count(), tamano_icono, separacion_iconos, ancho_visible)
	_iconos.add_theme_constant_override(&"separation", roundi(_separacion_actual))


func _on_icono_enfocado(carta: Carta, indice: int) -> void:
	_mostrar_carta(carta, indice)
	_seguir_icono(indice)


func _mostrar_carta(carta: Carta, indice: int) -> void:
	_carta.mostrar(carta, marcos[indice % marcos.size()])
	_carta.modulate = Color.WHITE
	_carta.position = Vector2(0.0, -_carta.size.y - espacio_carta)
	_carta.visible = true


func _seguir_icono(indice: int) -> void:
	var cantidad := _iconos.get_child_count()
	var paso := tamano_icono + _separacion_actual
	var ancho_visible := _ventana_cartas.size.x - margen_iconos * 2.0
	var total := cantidad * paso - _separacion_actual
	var vecino := _separacion_actual + tamano_icono * asomo
	var izquierda := indice * paso - (vecino if indice > 0 else 0.0)
	var derecha := indice * paso + tamano_icono + (vecino if indice < cantidad - 1 else 0.0)
	if derecha - _desplazamiento > ancho_visible:
		_desplazamiento = derecha - ancho_visible
	elif izquierda < _desplazamiento:
		_desplazamiento = izquierda
	_desplazamiento = clampf(_desplazamiento, 0.0, maxf(total - ancho_visible, 0.0))
	if _tween_iconos:
		_tween_iconos.kill()
	_tween_iconos = create_tween()
	_tween_iconos.tween_property(_iconos, "position:x", margen_iconos - _desplazamiento, duracion_desliz).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _armar_rondas(params: RondaParams, ronda: int) -> void:
	for hijo in _numeros.get_children():
		_numeros.remove_child(hijo)
		hijo.queue_free()
	for numero in range(1, params.cantidad_rondas + 1):
		var columna := VBoxContainer.new()
		columna.add_theme_constant_override(&"separation", roundi(espacio_evento))
		var evento := TextureRect.new()
		evento.texture = params.guion(numero).icono_evento
		evento.custom_minimum_size = Vector2(tamano_numero, alto_evento)
		evento.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		evento.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		evento.modulate.a = alpha_evento_pasado if numero < ronda else 1.0
		columna.add_child(evento)
		columna.add_child(_numero(numero, ronda))
		_numeros.add_child(columna)
	_ronda = ronda
	_cantidad_rondas = params.cantidad_rondas
	_ventana_rondas.custom_minimum_size.y = alto_evento + espacio_evento + tamano_numero + _margen_anillo() * 2.0
	_ubicar_rondas()


func _ubicar_rondas() -> void:
	if _cantidad_rondas == 0:
		return
	var margen := _margen_anillo()
	var ventana := _ventana_rondas.size.x
	var separacion := _separacion_para(_cantidad_rondas, tamano_numero, separacion_rondas, ventana - margen * 2.0)
	var ancho := _cantidad_rondas * tamano_numero + (_cantidad_rondas - 1) * separacion
	var alto := alto_evento + espacio_evento + tamano_numero
	_numeros.add_theme_constant_override(&"separation", roundi(separacion))
	_pista.size = Vector2(ancho, alto)
	_linea.position = Vector2(tamano_numero / 2.0, alto_evento + espacio_evento + (tamano_numero - grosor_linea) / 2.0)
	_linea.size = Vector2(ancho - tamano_numero, grosor_linea)
	var x := ventana - margen - ancho
	if ancho + margen * 2.0 > ventana:
		var centro := (_ronda - 1) * (tamano_numero + separacion) + tamano_numero / 2.0
		x = clampf(ventana / 2.0 - centro, ventana - margen - ancho, margen)
	_pista.position = Vector2(x, margen)


func _margen_anillo() -> float:
	return separacion_anillo + grosor_borde


func _numero(numero: int, ronda: int) -> Control:
	var circulo := PanelContainer.new()
	circulo.custom_minimum_size = Vector2.ONE * tamano_numero
	var estilo := StyleBoxFlat.new()
	estilo.set_corner_radius_all(ceili(tamano_numero / 2.0))
	var texto := Label.new()
	texto.theme_type_variation = &"Destacado"
	texto.text = str(numero)
	texto.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	texto.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	texto.add_theme_font_size_override(&"font_size", tamano_texto_numero)
	texto.add_theme_constant_override(&"outline_size", 0)
	texto.add_theme_constant_override(&"shadow_outline_size", 0)
	texto.add_theme_color_override(&"font_shadow_color", Color.TRANSPARENT)
	if numero < ronda:
		estilo.bg_color = color_pasada
		texto.add_theme_color_override(&"font_color", color_texto_oscuro)
	elif numero == ronda:
		estilo.bg_color = color_actual
		texto.add_theme_color_override(&"font_color", color_texto_oscuro)
		circulo.add_child(_anillo())
	else:
		estilo.bg_color = color_fondo_numero
		estilo.set_border_width_all(grosor_borde)
		estilo.border_color = color_futura
		texto.add_theme_color_override(&"font_color", color_texto_claro)
	circulo.add_theme_stylebox_override(&"panel", estilo)
	circulo.add_child(texto)
	return circulo


func _anillo() -> Panel:
	var estilo := StyleBoxFlat.new()
	estilo.draw_center = false
	estilo.set_border_width_all(grosor_borde)
	estilo.border_color = color_actual
	estilo.set_corner_radius_all(ceili(tamano_numero / 2.0 + separacion_anillo))
	estilo.set_expand_margin_all(separacion_anillo)
	var anillo := Panel.new()
	anillo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	anillo.add_theme_stylebox_override(&"panel", estilo)
	return anillo
