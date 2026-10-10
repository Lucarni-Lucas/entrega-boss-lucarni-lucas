extends CanvasLayer

enum Accion { MOVER, SALTO, SLASH, LANZAMIENTO, DIVE, REBOTE, GROUND_POUND }
enum Fase { VERBOS, CADENA, FINAL }

const _BOTON_CRUZ := preload("res://assets/ui/botones/cruz.svg")
const _BOTON_CIRCULO := preload("res://assets/ui/botones/circulo.svg")
const _BOTON_CUADRADO := preload("res://assets/ui/botones/cuadrado.svg")
const _BOTON_TRIANGULO := preload("res://assets/ui/botones/triangulo.svg")
const _PASOS := [Accion.MOVER, Accion.SALTO, Accion.SLASH, Accion.LANZAMIENTO, Accion.DIVE, Accion.REBOTE, Accion.GROUND_POUND]
const _CADENA := [Accion.SALTO, Accion.LANZAMIENTO, Accion.DIVE, Accion.REBOTE, Accion.GROUND_POUND]
const _INSTRUCCIONES := {
	Accion.MOVER: ["Movete", "Flechas / WASD / Stick izq", null],
	Accion.SALTO: ["Saltá", "Espacio / V /", _BOTON_CRUZ],
	Accion.SLASH: ["Atacá con el slash", "C / Clic izq /", _BOTON_CUADRADO],
	Accion.LANZAMIENTO: ["En el aire, tirá el boomerang", "Shift / Z /", _BOTON_CIRCULO],
	Accion.DIVE: ["En el aire, hacé dive", "Clic der / X /", _BOTON_TRIANGULO],
	Accion.REBOTE: ["Rebotá en el boomerang", "Saltá, tiralo y hacé dive hacia él para tocarlo en el aire", null],
	Accion.GROUND_POUND: ["Desde arriba, hacé ground pound", "En el aire, apretá saltar otra vez", null],
}
const _DIRECCIONES := ["mover_izquierda", "mover_arriba", "mover_abajo", "mover_derecha"]
const _DETALLE_CADENA := "Ahora todo seguido, sin tocar el suelo"
const _DETALLE_ENERGIA := "Gasta energía: si lo repetís seguido, sale débil"
const _TITULO_REINTENTO := "UNA CADENA MÁS"
const _AVISO_SUELO := "Tocaste el suelo, empezá la cadena de nuevo"
const _AVISO_LANZAR_EN_SUELO := "También se puede tirar en el suelo pero prueba en el aire"

@export var params: TutorialParams
@export var jugador: Player
@export_file("*.tscn") var escena_partida: String
@export var color_inactivo := Color(0.5, 0.5, 0.5)
@export_range(0, 1, 0.05) var alpha_bloqueado := 0.35

var _fase := Fase.VERBOS
var _paso := 0
var _cadenas := 0
var _reintento := false
var _direcciones_hechas: Array[bool] = [false, false, false, false]
var _estado_previo: Player.Estado
var _en_suelo_previo := true
var _espera := 0.0
var _al_terminar_espera: Callable
var _tiempo_aviso := 0.0
var _bloqueado := false

@onready var _pasos: Control = $Pasos
@onready var _instruccion: Label = $Pasos/Instruccion
@onready var _linea_detalle: HBoxContainer = $Pasos/LineaDetalle
@onready var _detalle: Label = $Pasos/LineaDetalle/Detalle
@onready var _boton_joystick: TextureRect = $Pasos/LineaDetalle/BotonJoystick
@onready var _fila_puntos: HBoxContainer = $Pasos/Puntos
@onready var _puntos := _fila_puntos.get_children()
@onready var _direcciones: HBoxContainer = $Pasos/Direcciones
@onready var _flechas := _direcciones.get_children()
@onready var _cadena: HBoxContainer = $Pasos/Cadena
@onready var _pasos_cadena: Array[Label] = [$Pasos/Cadena/Saltar, $Pasos/Cadena/Boomerang, $Pasos/Cadena/Dive, $Pasos/Cadena/Rebote, $Pasos/Cadena/GroundPound]
@onready var _aviso: Label = $Pasos/Aviso
@onready var _final: Control = $Final
@onready var _reintentar: Button = $Final/Contenido/ReintentarCadena
@onready var _empezar_partida: Button = $Final/Contenido/EmpezarPartida


func _ready() -> void:
	_estado_previo = jugador.estado_actual()
	_en_suelo_previo = jugador.esta_en_suelo()
	_reintentar.pressed.connect(_reintentar_cadena)
	_empezar_partida.pressed.connect(_ir_a_la_partida)
	_actualizar_puntos()
	_actualizar_flechas()
	_mostrar_verbo()


func _input(_event: InputEvent) -> void:
	if _bloqueado:
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if _tiempo_aviso > 0.0:
		_tiempo_aviso -= delta
		_aviso.visible = _tiempo_aviso > 0.0
	if _espera > 0.0:
		_espera -= delta
		if _espera <= 0.0:
			_al_terminar_espera.call()


func _physics_process(_delta: float) -> void:
	if _escuchando() and _esperada() == Accion.MOVER:
		_revisar_direcciones()
	var estado := jugador.estado_actual()
	var en_suelo := jugador.esta_en_suelo()
	if _en_suelo_previo and not en_suelo:
		_registrar(Accion.SALTO)
	if estado != _estado_previo:
		if estado == Player.Estado.THROW:
			_lanzo(en_suelo)
		elif estado == Player.Estado.DIVE:
			_registrar(Accion.DIVE)
		elif _estado_previo == Player.Estado.GROUND_POUND and en_suelo:
			_registrar(Accion.GROUND_POUND)
	if en_suelo and not _en_suelo_previo and estado != Player.Estado.GROUND_POUND:
		_toco_el_suelo()
	_estado_previo = estado
	_en_suelo_previo = en_suelo


func _on_player_reboto() -> void:
	if not jugador.esta_en_suelo():
		_registrar(Accion.REBOTE)


func _on_slash_slasheo() -> void:
	_registrar(Accion.SLASH)


func _on_menu_partida_pauso() -> void:
	visible = false


func _on_menu_partida_reanudo() -> void:
	visible = true
	get_tree().paused = false
	if _fase == Fase.FINAL and not _bloqueado:
		_reintentar.grab_focus()


func _on_menu_partida_saltar_paso_pedido() -> void:
	_ocultar_aviso()
	if _espera > 0.0:
		_espera = 0.0
		_al_terminar_espera.call()
	elif _fase == Fase.VERBOS:
		_paso += 1
		_actualizar_puntos()
		if _paso < _PASOS.size():
			_mostrar_verbo()
		else:
			_empezar_cadena()
	elif _fase == Fase.CADENA:
		_cadenas += 1
		if _terminaron_las_cadenas():
			_mostrar_final()
		else:
			_empezar_cadena()
	else:
		_ir_a_la_partida()


func _escuchando() -> bool:
	return _fase != Fase.FINAL and _espera <= 0.0


func _esperada() -> Accion:
	return _PASOS[_paso] if _fase == Fase.VERBOS else _CADENA[_paso]


func _registrar(accion: Accion) -> void:
	if not _escuchando():
		return
	if accion == _esperada():
		if _fase == Fase.VERBOS:
			_completar_verbo()
		else:
			_avanzar_cadena()
	elif _fase == Fase.CADENA and accion == Accion.GROUND_POUND and _paso > 0:
		_romper_cadena()


func _revisar_direcciones() -> void:
	for i in _DIRECCIONES.size():
		if Input.is_action_pressed(_DIRECCIONES[i]):
			_direcciones_hechas[i] = true
	_actualizar_flechas()
	if not _direcciones_hechas.has(false):
		_registrar(Accion.MOVER)


func _lanzo(en_suelo: bool) -> void:
	if not en_suelo:
		_registrar(Accion.LANZAMIENTO)
	elif _escuchando() and _esperada() == Accion.LANZAMIENTO:
		_avisar(_AVISO_LANZAR_EN_SUELO)


func _toco_el_suelo() -> void:
	if _escuchando() and _fase == Fase.CADENA and _paso > 0:
		_romper_cadena()


func _completar_verbo() -> void:
	var completada: Accion = _PASOS[_paso]
	_paso += 1
	_ocultar_aviso()
	_actualizar_puntos()
	var despues: Callable = _mostrar_verbo if _paso < _PASOS.size() else _empezar_cadena
	if completada == Accion.GROUND_POUND:
		_celebrar("¡Bien!", _DETALLE_ENERGIA, params.duracion_energia, despues)
	else:
		_celebrar("¡Bien!", "", params.duracion_bien, despues)


func _mostrar_verbo() -> void:
	var accion: Accion = _PASOS[_paso]
	var textos: Array = _INSTRUCCIONES[accion]
	_mostrar_texto(textos[0], textos[1], textos[2])
	_direcciones.visible = accion == Accion.MOVER


func _empezar_cadena() -> void:
	_fase = Fase.CADENA
	_paso = 0
	_fila_puntos.visible = false
	_direcciones.visible = false
	_cadena.visible = true
	_mostrar_texto(_titulo_cadena(), _DETALLE_CADENA)
	_actualizar_cadena()


func _titulo_cadena() -> String:
	if _reintento:
		return _TITULO_REINTENTO
	return "CADENA %d / %d" % [_cadenas + 1, params.cadenas_necesarias]


func _avanzar_cadena() -> void:
	_paso += 1
	_ocultar_aviso()
	_actualizar_cadena()
	if _paso < _CADENA.size():
		return
	_cadenas += 1
	if _terminaron_las_cadenas():
		_celebrar("¡CADENA COMPLETA!", "", params.duracion_final, _mostrar_final)
	else:
		_celebrar("¡Bien!", "Una vez más", params.duracion_bien, _empezar_cadena)


func _terminaron_las_cadenas() -> bool:
	return _reintento or _cadenas >= params.cadenas_necesarias


func _romper_cadena() -> void:
	_paso = 0
	_actualizar_cadena()
	_avisar(_AVISO_SUELO)


func _celebrar(titulo: String, detalle: String, duracion: float, despues: Callable) -> void:
	_mostrar_texto(titulo, detalle)
	_espera = duracion
	_al_terminar_espera = despues


func _mostrar_texto(titulo: String, detalle: String, boton: Texture2D = null) -> void:
	_instruccion.text = titulo
	_detalle.text = detalle
	_linea_detalle.visible = detalle != ""
	_boton_joystick.texture = boton
	_boton_joystick.visible = boton != null


func _avisar(texto: String) -> void:
	_aviso.text = texto
	_aviso.visible = true
	_tiempo_aviso = params.duracion_aviso


func _ocultar_aviso() -> void:
	_tiempo_aviso = 0.0
	_aviso.visible = false


func _actualizar_puntos() -> void:
	for i in _puntos.size():
		_puntos[i].modulate = Color.WHITE if i <= _paso else color_inactivo


func _actualizar_flechas() -> void:
	for i in _flechas.size():
		_flechas[i].modulate = Color.WHITE if _direcciones_hechas[i] else color_inactivo


func _actualizar_cadena() -> void:
	for i in _pasos_cadena.size():
		var etiqueta := _pasos_cadena[i]
		if i < _paso:
			etiqueta.remove_theme_color_override("font_color")
			etiqueta.remove_theme_color_override("font_shadow_color")
		else:
			etiqueta.add_theme_color_override("font_color", Color.WHITE if i == _paso else color_inactivo)
			etiqueta.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
		etiqueta.get_node("Marca").visible = i == _paso


func _mostrar_final() -> void:
	_fase = Fase.FINAL
	jugador.process_mode = Node.PROCESS_MODE_DISABLED
	jugador.visible = false
	_pasos.visible = false
	_final.visible = true
	_bloqueado = true
	_atenuar_botones(alpha_bloqueado)
	_espera = params.bloqueo_final
	_al_terminar_espera = _desbloquear_final


func _desbloquear_final() -> void:
	_bloqueado = false
	_atenuar_botones(1.0)
	_reintentar.grab_focus()


func _atenuar_botones(alpha: float) -> void:
	_reintentar.modulate.a = alpha
	_empezar_partida.modulate.a = alpha


func _reintentar_cadena() -> void:
	_reintento = true
	_final.visible = false
	_pasos.visible = true
	jugador.visible = true
	jugador.process_mode = Node.PROCESS_MODE_INHERIT
	_empezar_cadena()


func _ir_a_la_partida() -> void:
	get_tree().change_scene_to_file(escena_partida)
