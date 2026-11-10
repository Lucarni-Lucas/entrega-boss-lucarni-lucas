extends CanvasLayer

signal pauso
signal reanudo
signal volvio_a_cartas
signal saltar_paso_pedido

@export_range(0, 1, 0.05, "suffix:s") var duracion_entrada := 0.2
@export_file("*.tscn") var escena_menu: String
@export var params: RondaParams
@export var cartas: Cartas
@export_range(0, 1, 0.05) var alpha_bloqueado := 0.35
@export_range(0, 400, 1, "suffix:px") var subida_con_resumen := 110.0
@export var con_saltar_paso := false
@export var titulos_derrota: Array[String] = ["¡UNA MÁS!", "¡NO TE RINDAS!"]

var _en_pausa := false
var _bloqueado := false
var _finalizada := false
var _entre_rondas := false
var _ronda := 1
var _con_resumen := false
var _offsets_opciones: Vector2

@onready var _contenido: Control = $Contenido
@onready var _opciones: VBoxContainer = $Contenido/Opciones
@onready var _titulo: Label = $Contenido/Opciones/Titulo
@onready var _reanudar: Button = $Contenido/Opciones/Reanudar
@onready var _saltar_paso: Button = $Contenido/Opciones/SaltarPaso
@onready var _reintentar: Button = $Contenido/Opciones/Reintentar
@onready var _boton_controles: Button = $Contenido/Opciones/Controles
@onready var _menu_principal: Button = $Contenido/Opciones/MenuPrincipal
@onready var _resumen: ResumenPartida = $Contenido/Resumen
@onready var _controles := $Contenido/Controles
@onready var _boton_ajustes: Button = $Contenido/Opciones/Ajustes
@onready var _ajustes := $Contenido/Ajustes


func _ready() -> void:
	_offsets_opciones = Vector2(_opciones.offset_top, _opciones.offset_bottom)
	_reanudar.pressed.connect(_reanudar_partida)
	_saltar_paso.pressed.connect(_on_saltar_paso_pressed)
	_reintentar.pressed.connect(_on_reintentar_pressed)
	_boton_controles.pressed.connect(_abrir_controles)
	_menu_principal.pressed.connect(_on_menu_principal_pressed)
	_controles.cerrado.connect(_on_controles_cerrado)
	_boton_ajustes.pressed.connect(_abrir_ajustes)
	_ajustes.cerrado.connect(_on_ajustes_cerrado)


func _unhandled_input(event: InputEvent) -> void:
	if _finalizada or _controles.visible or _ajustes.visible:
		return
	if event.is_action_pressed("pausa"):
		if _en_pausa:
			_reanudar_partida()
		else:
			pausar()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and not _finalizada and not _en_pausa and not _entre_rondas and not _sin_pausa_por_foco():
		pausar()


func _sin_pausa_por_foco() -> bool:
	return "--sin-pausa-por-foco" in OS.get_cmdline_user_args()


func _on_partida_finalizo(gano: bool) -> void:
	_finalizada = true
	_mostrar("¡GANASTE!" if gano else titulos_derrota.pick_random(), false)


func pausar() -> void:
	_en_pausa = true
	get_tree().paused = true
	pauso.emit()
	_mostrar("PAUSA", true)


func _reanudar_partida() -> void:
	_en_pausa = false
	visible = false
	if _entre_rondas:
		volvio_a_cartas.emit()
	else:
		reanudo.emit()


func _on_saltar_paso_pressed() -> void:
	_reanudar_partida()
	saltar_paso_pedido.emit()


func _mostrar(titulo: String, en_pausa: bool) -> void:
	_titulo.text = titulo
	_reanudar.visible = en_pausa
	_boton_controles.visible = en_pausa
	_boton_ajustes.visible = en_pausa
	_saltar_paso.visible = en_pausa and con_saltar_paso
	_reintentar.visible = not en_pausa
	_mostrar_resumen(en_pausa and cartas != null)
	visible = true
	_contenido.modulate.a = 0.0
	create_tween().tween_property(_contenido, "modulate:a", 1.0, duracion_entrada)
	if en_pausa:
		_reanudar.grab_focus()
	else:
		_bloquear_botones()


func _mostrar_resumen(mostrar: bool) -> void:
	_con_resumen = mostrar
	_resumen.visible = mostrar
	var subida := subida_con_resumen if mostrar else 0.0
	_opciones.offset_top = _offsets_opciones.x - subida
	_opciones.offset_bottom = _offsets_opciones.y - subida
	var iconos: Array[Node] = []
	if mostrar:
		_resumen.mostrar(cartas.tomadas, params, _ronda)
		iconos = _resumen.iconos()
	_menu_principal.focus_neighbor_bottom = _menu_principal.get_path_to(iconos[0]) if not iconos.is_empty() else NodePath()
	for icono: Control in iconos:
		icono.focus_neighbor_top = icono.get_path_to(_menu_principal)


func _input(_event: InputEvent) -> void:
	if _bloqueado:
		get_viewport().set_input_as_handled()


func _bloquear_botones() -> void:
	_bloqueado = true
	_atenuar_botones(alpha_bloqueado)
	await get_tree().create_timer(params.bloqueo_final).timeout
	_bloqueado = false
	_atenuar_botones(1.0)
	_reintentar.grab_focus()


func _atenuar_botones(alpha: float) -> void:
	_reintentar.modulate.a = alpha
	_menu_principal.modulate.a = alpha


func _abrir_controles() -> void:
	_opciones.visible = false
	_resumen.visible = false
	_controles.abrir()


func _on_controles_cerrado() -> void:
	_opciones.visible = true
	_resumen.visible = _con_resumen
	_boton_controles.grab_focus()


func _abrir_ajustes() -> void:
	_opciones.visible = false
	_resumen.visible = false
	_ajustes.abrir()


func _on_ajustes_cerrado() -> void:
	_opciones.visible = true
	_resumen.visible = _con_resumen
	_boton_ajustes.grab_focus()


func _on_reintentar_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_principal_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(escena_menu)


func _on_partida_ronda_superada(numero: int, _total: int) -> void:
	_entre_rondas = true
	_ronda = numero + 1


func _on_partida_ronda_empezo(numero: int, _total: int) -> void:
	_entre_rondas = false
	_ronda = numero
