extends Control

@export_file("*.tscn") var escena_tutorial: String
@export_file("*.tscn") var escena_partida: String

@onready var _opciones: VBoxContainer = $Opciones
@onready var _empezar_partida: Button = $Opciones/EmpezarPartida
@onready var _boton_controles: Button = $Opciones/Controles
@onready var _controles := $Controles
@onready var _pregunta: VBoxContainer = $Pregunta
@onready var _hacer_tutorial: Button = $Pregunta/HacerTutorial
@onready var _jugar_directo: Button = $Pregunta/JugarDirecto


func _ready() -> void:
	_empezar_partida.pressed.connect(_abrir_pregunta)
	_boton_controles.pressed.connect(_abrir_controles)
	_controles.cerrado.connect(_on_controles_cerrado)
	_hacer_tutorial.pressed.connect(_ir_a.bind(escena_tutorial))
	_jugar_directo.pressed.connect(_ir_a.bind(escena_partida))
	_empezar_partida.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if _pregunta.visible and event.is_action_pressed("ui_cancel"):
		_cerrar_pregunta()
		get_viewport().set_input_as_handled()


func _abrir_pregunta() -> void:
	_opciones.visible = false
	_pregunta.visible = true
	_hacer_tutorial.grab_focus()


func _cerrar_pregunta() -> void:
	_pregunta.visible = false
	_opciones.visible = true
	_empezar_partida.grab_focus()


func _ir_a(escena: String) -> void:
	get_tree().change_scene_to_file(escena)


func _abrir_controles() -> void:
	_opciones.visible = false
	_controles.abrir()


func _on_controles_cerrado() -> void:
	_opciones.visible = true
	_boton_controles.grab_focus()
