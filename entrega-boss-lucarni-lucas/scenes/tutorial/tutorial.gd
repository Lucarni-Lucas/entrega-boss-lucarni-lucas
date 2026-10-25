extends CanvasLayer

enum Accion { MOVER, SALTO, SLASH, LANZAMIENTO, DIVE, REBOTE, GROUND_POUND }
enum Fase { VERBOS, CADENA, FINAL }

const _ICONO := preload("res://scenes/ui/icono_tecla.tscn")
const _PASOS := [Accion.MOVER, Accion.SALTO, Accion.SLASH, Accion.LANZAMIENTO, Accion.DIVE, Accion.REBOTE, Accion.GROUND_POUND]
const _CADENA := [Accion.SALTO, Accion.LANZAMIENTO, Accion.DIVE, Accion.REBOTE, Accion.GROUND_POUND]
const _INSTRUCCIONES := {
	Accion.MOVER: "Primero, probá moverte un poco",
	Accion.SALTO: "Ahora, animate a dar un salto",
	Accion.SLASH: "Podés defenderte usándome",
	Accion.LANZAMIENTO: "Desde el aire, tirame sin miedo",
	Accion.DIVE: "En pleno salto, lanzate con un dive",
	Accion.REBOTE: "¡Mi favorito! Probá rebotar sobre mí",
	Accion.GROUND_POUND: "Para cerrar, ¡un buen ground pound!",
}
const _SECUENCIAS := {
	Accion.MOVER: [Accion.MOVER],
	Accion.SALTO: [Accion.SALTO],
	Accion.SLASH: [Accion.SLASH],
	Accion.LANZAMIENTO: [Accion.SALTO, Accion.LANZAMIENTO],
	Accion.DIVE: [Accion.SALTO, Accion.DIVE],
	Accion.REBOTE: [Accion.SALTO, Accion.LANZAMIENTO, Accion.DIVE, Accion.REBOTE],
	Accion.GROUND_POUND: [Accion.SALTO, Accion.GROUND_POUND],
}
const _TECLAS := {
	Accion.SALTO: "saltar",
	Accion.SLASH: "slash",
	Accion.LANZAMIENTO: "boomerang",
	Accion.DIVE: "dive",
	Accion.GROUND_POUND: "ground_pound",
}
const _SALUDO := "¡Hola! Soy Boomie"
const _DETALLE_SALUDO := "Dejame enseñarte lo básico"
const _FESTEJOS := ["¡Bien!", "¡Eso!", "¡Genial!", "¡Muy bien!"]
const _DETALLE_ENERGIA := "Ojo, que cansa. Si lo repetís muy seguido, sale débil"
const _PRESENTACION_CADENA := "Ahora, intentemos algo más difícil"
const _DETALLE_PRESENTACION_CADENA := "Hacé todo seguido sin tocar el suelo"
const _TITULO_REINTENTO := "UNA CADENA MÁS"
const _AVISO_SUELO := "¡Uy, tocaste el suelo! Arrancá la cadena de nuevo"
const _AVISO_LANZAR_EN_SUELO := "También podés tirarme en el suelo, pero probá en el aire"

@export var params: TutorialParams
@export var jugador: Player
@export_file("*.tscn") var escena_partida: String
@export var color_inactivo := Color(0.5, 0.5, 0.5)
@export_range(0, 1, 0.05) var alpha_bloqueado := 0.35

var _fase := Fase.VERBOS
var _paso := 0
var _progreso := 0
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
@onready var _teclas: HBoxContainer = $Pasos/Teclas
@onready var _fila_puntos: HBoxContainer = $Pasos/Puntos
@onready var _puntos := _fila_puntos.get_children()
@onready var _cadena: HBoxContainer = $Pasos/Cadena
@onready var _modelo_flecha: Label = $Pasos/Cadena/Flecha1
@onready var _nombres_cadena: Array[Label] = [$Pasos/Cadena/Saltar/Nombre, $Pasos/Cadena/Boomerang/Nombre, $Pasos/Cadena/Dive/Nombre, $Pasos/Cadena/Rebote/Nombre, $Pasos/Cadena/GroundPound/Nombre]
@onready var _teclas_cadena: Array[IconoTecla] = [$Pasos/Cadena/Saltar/Tecla, $Pasos/Cadena/Boomerang/Tecla, $Pasos/Cadena/Dive/Tecla, $Pasos/Cadena/Rebote/Tecla, $Pasos/Cadena/GroundPound/Tecla]
@onready var _aviso: Label = $Pasos/Aviso
@onready var _tecla_pausa: IconoTecla = $Pasos/AvisoPausa/Tecla
@onready var _boomie: Boomie = $Pasos/Boomie
@onready var _final: Control = $Final
@onready var _reintentar: Button = $Final/Contenido/ReintentarCadena
@onready var _empezar_partida: Button = $Final/Contenido/EmpezarPartida


func _ready() -> void:
	_estado_previo = jugador.estado_actual()
	_en_suelo_previo = jugador.esta_en_suelo()
	_reintentar.pressed.connect(_reintentar_cadena)
	_empezar_partida.pressed.connect(_ir_a_la_partida)
	EsquemaInput.cambio.connect(_on_esquema_cambio)
	_actualizar_puntos()
	_actualizar_texturas()
	_boomie.entrar(true)
	_saludar()


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


func _on_player_slasheo() -> void:
	_registrar(Accion.SLASH)


func _on_esquema_cambio(_esquema: EsquemaInput.Esquema) -> void:
	_actualizar_texturas()


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
			_presentar_cadena()
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


func _secuencia() -> Array:
	return _SECUENCIAS[_PASOS[_paso]] if _fase == Fase.VERBOS else _CADENA


func _esperada() -> Accion:
	return _secuencia()[_progreso]


func _registrar(accion: Accion) -> void:
	if not _escuchando():
		return
	if accion == _esperada():
		_avanzar()
	elif _fase == Fase.CADENA and accion == Accion.GROUND_POUND and _progreso > 0:
		_romper_cadena()


func _avanzar() -> void:
	_progreso += 1
	_ocultar_aviso()
	if _fase == Fase.VERBOS:
		_actualizar_teclas()
	else:
		_actualizar_cadena()
	if _progreso < _secuencia().size():
		return
	if _fase == Fase.VERBOS:
		_completar_verbo()
	else:
		_completar_cadena()


func _revisar_direcciones() -> void:
	for i in EsquemaInput.DIRECCIONES.size():
		if Input.is_action_pressed(EsquemaInput.DIRECCIONES[i]):
			_direcciones_hechas[i] = true
	_actualizar_teclas()
	if not _direcciones_hechas.has(false):
		_registrar(Accion.MOVER)


func _lanzo(en_suelo: bool) -> void:
	if not en_suelo:
		_registrar(Accion.LANZAMIENTO)
	elif _escuchando() and _fase == Fase.VERBOS and _PASOS[_paso] == Accion.LANZAMIENTO:
		_avisar(_AVISO_LANZAR_EN_SUELO)


func _toco_el_suelo() -> void:
	if not _escuchando() or _progreso == 0:
		return
	if _fase == Fase.CADENA:
		_romper_cadena()
	else:
		_progreso = 0
		_actualizar_teclas()


func _completar_verbo() -> void:
	var completada: Accion = _PASOS[_paso]
	_paso += 1
	_actualizar_puntos()
	var despues: Callable = _mostrar_verbo if _paso < _PASOS.size() else _presentar_cadena
	if completada == Accion.GROUND_POUND:
		_celebrar(_FESTEJOS.pick_random(), _DETALLE_ENERGIA, params.duracion_energia, despues)
	else:
		_celebrar(_FESTEJOS.pick_random(), "", params.duracion_bien, despues)


func _mostrar_verbo() -> void:
	_progreso = 0
	_fila_puntos.visible = true
	var accion: Accion = _PASOS[_paso]
	_mostrar_texto(_INSTRUCCIONES[accion])
	_armar_teclas(accion)
	_teclas.visible = true
	_actualizar_teclas()


func _armar_teclas(accion: Accion) -> void:
	for hijo in _teclas.get_children():
		_teclas.remove_child(hijo)
		hijo.queue_free()
	var acciones_input: Array = EsquemaInput.DIRECCIONES if accion == Accion.MOVER else _acciones_input(_SECUENCIAS[accion])
	for i in acciones_input.size():
		if i > 0 and accion != Accion.MOVER:
			var flecha: Label = _modelo_flecha.duplicate()
			flecha.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			_teclas.add_child(flecha)
		var icono: IconoTecla = _ICONO.instantiate()
		icono.accion = acciones_input[i]
		_teclas.add_child(icono)
	_actualizar_texturas()


func _acciones_input(secuencia: Array) -> Array:
	var acciones: Array = []
	for accion: Accion in secuencia:
		if _TECLAS.has(accion):
			acciones.append(_TECLAS[accion])
	return acciones


func _saludar() -> void:
	_teclas.visible = false
	_fila_puntos.visible = false
	_mostrar_texto(_SALUDO, _DETALLE_SALUDO)
	_espera = params.duracion_saludo
	_al_terminar_espera = _mostrar_verbo


func _presentar_cadena() -> void:
	_teclas.visible = false
	_fila_puntos.visible = false
	_mostrar_texto(_PRESENTACION_CADENA, _DETALLE_PRESENTACION_CADENA)
	_espera = params.duracion_presentacion_cadena
	_al_terminar_espera = _empezar_cadena


func _empezar_cadena() -> void:
	_fase = Fase.CADENA
	_progreso = 0
	_fila_puntos.visible = false
	_teclas.visible = false
	_cadena.visible = true
	_mostrar_texto(_titulo_cadena())
	_actualizar_cadena()


func _titulo_cadena() -> String:
	if _reintento:
		return _TITULO_REINTENTO
	return "CADENA %d / %d" % [_cadenas + 1, params.cadenas_necesarias]


func _completar_cadena() -> void:
	_cadenas += 1
	if _terminaron_las_cadenas():
		_celebrar("¡CADENA COMPLETA!", "", params.duracion_final, _mostrar_final)
	else:
		_celebrar(_FESTEJOS.pick_random(), "¡Dale, una vez más!", params.duracion_bien, _empezar_cadena)


func _terminaron_las_cadenas() -> bool:
	return _reintento or _cadenas >= params.cadenas_necesarias


func _romper_cadena() -> void:
	_progreso = 0
	_actualizar_cadena()
	_avisar(_AVISO_SUELO)


func _celebrar(titulo: String, detalle: String, duracion: float, despues: Callable) -> void:
	_teclas.visible = false
	_cadena.visible = false
	_mostrar_texto(titulo, detalle)
	_boomie.festejar()
	_espera = duracion
	_al_terminar_espera = despues


func _mostrar_texto(titulo: String, detalle := "") -> void:
	_instruccion.text = titulo
	_detalle.text = detalle
	_linea_detalle.visible = detalle != ""
	_boomie.hablar()


func _actualizar_texturas() -> void:
	for icono in _iconos_de_teclas():
		_poner_tecla(icono, icono.accion)
	for i in _CADENA.size():
		if _TECLAS.has(_CADENA[i]):
			_poner_tecla(_teclas_cadena[i], _TECLAS[_CADENA[i]])
	_tecla_pausa.textura = EsquemaInput.tecla("pausa")


func _poner_tecla(icono: IconoTecla, accion: String) -> void:
	icono.accion = accion
	icono.esquema = EsquemaInput.actual
	icono.textura = EsquemaInput.tecla(accion)


func _iconos_de_teclas() -> Array:
	return _teclas.get_children().filter(func(hijo: Node) -> bool: return hijo is IconoTecla)


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


func _actualizar_teclas() -> void:
	var mover: bool = _PASOS[_paso] == Accion.MOVER
	var iconos := _iconos_de_teclas()
	for i in iconos.size():
		if mover:
			iconos[i].mostrar(IconoTecla.Estado.HECHA if _direcciones_hechas[i] else IconoTecla.Estado.APAGADA)
		else:
			iconos[i].mostrar(_estado_de_tecla(i))


func _actualizar_cadena() -> void:
	for i in _nombres_cadena.size():
		var nombre := _nombres_cadena[i]
		if i < _progreso:
			nombre.remove_theme_color_override("font_color")
			nombre.remove_theme_color_override("font_shadow_color")
		else:
			nombre.add_theme_color_override("font_color", Color.WHITE if i == _progreso else color_inactivo)
			nombre.add_theme_color_override("font_shadow_color", Color.TRANSPARENT)
		_teclas_cadena[i].mostrar(_estado_de_tecla(i))


func _estado_de_tecla(indice: int) -> IconoTecla.Estado:
	if indice < _progreso:
		return IconoTecla.Estado.HECHA
	if indice == _progreso:
		return IconoTecla.Estado.SIGUIENTE
	return IconoTecla.Estado.APAGADA


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
	_boomie.entrar()
	_empezar_cadena()


func _ir_a_la_partida() -> void:
	get_tree().change_scene_to_file(escena_partida)
