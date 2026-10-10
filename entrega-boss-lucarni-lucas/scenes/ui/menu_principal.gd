extends Control

@export_file("*.tscn") var escena_partida: String

@onready var _opciones: VBoxContainer = $Opciones
@onready var _empezar_partida: Button = $Opciones/EmpezarPartida
@onready var _boton_controles: Button = $Opciones/Controles
@onready var _controles := $Controles


func _ready() -> void:
	_empezar_partida.pressed.connect(_on_empezar_partida_pressed)
	_boton_controles.pressed.connect(_abrir_controles)
	_controles.cerrado.connect(_on_controles_cerrado)
	_empezar_partida.grab_focus()


func _on_empezar_partida_pressed() -> void:
	get_tree().change_scene_to_file(escena_partida)


func _abrir_controles() -> void:
	_opciones.visible = false
	_controles.abrir()


func _on_controles_cerrado() -> void:
	_opciones.visible = true
	_boton_controles.grab_focus()
