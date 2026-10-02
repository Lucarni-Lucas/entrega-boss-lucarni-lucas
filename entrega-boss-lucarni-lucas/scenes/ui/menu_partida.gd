extends CanvasLayer

@export_range(0, 1, 0.05, "suffix:s") var duracion_entrada := 0.2
@export_file("*.tscn") var escena_menu: String

var _en_pausa := false
var _finalizada := false

@onready var _contenido: Control = $Contenido
@onready var _opciones: VBoxContainer = $Contenido/Opciones
@onready var _titulo: Label = $Contenido/Opciones/Titulo
@onready var _reanudar: Button = $Contenido/Opciones/Reanudar
@onready var _reintentar: Button = $Contenido/Opciones/Reintentar
@onready var _boton_controles: Button = $Contenido/Opciones/Controles
@onready var _menu_principal: Button = $Contenido/Opciones/MenuPrincipal
@onready var _controles := $Contenido/Controles


func _ready() -> void:
	_reanudar.pressed.connect(_reanudar_partida)
	_reintentar.pressed.connect(_on_reintentar_pressed)
	_boton_controles.pressed.connect(_abrir_controles)
	_menu_principal.pressed.connect(_on_menu_principal_pressed)
	_controles.cerrado.connect(_on_controles_cerrado)


func _unhandled_input(event: InputEvent) -> void:
	if _finalizada or _controles.visible:
		return
	if event.is_action_pressed("pausa"):
		if _en_pausa:
			_reanudar_partida()
		else:
			_pausar()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and not _finalizada and not _en_pausa:
		_pausar()


func _on_partida_finalizo(gano: bool) -> void:
	_finalizada = true
	_mostrar("¡GANASTE!" if gano else "MORISTE", false)


func _pausar() -> void:
	_en_pausa = true
	get_tree().paused = true
	_mostrar("PAUSA", true)


func _reanudar_partida() -> void:
	_en_pausa = false
	visible = false
	get_tree().paused = false


func _mostrar(titulo: String, en_pausa: bool) -> void:
	_titulo.text = titulo
	_reanudar.visible = en_pausa
	_boton_controles.visible = en_pausa
	_reintentar.visible = not en_pausa
	visible = true
	_contenido.modulate.a = 0.0
	create_tween().tween_property(_contenido, "modulate:a", 1.0, duracion_entrada)
	(_reanudar if en_pausa else _reintentar).grab_focus()


func _abrir_controles() -> void:
	_opciones.visible = false
	_controles.abrir(false)


func _on_controles_cerrado() -> void:
	_opciones.visible = true
	_boton_controles.grab_focus()


func _on_reintentar_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_principal_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(escena_menu)
