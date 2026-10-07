extends Control

@export_file("*.tscn") var escena_partida: String

var _boton_que_abrio: Button

@onready var _opciones: VBoxContainer = $Opciones
@onready var _jugar: Button = $Opciones/Jugar
@onready var _boton_controles: Button = $Opciones/Controles
@onready var _controles := $Controles


func _ready() -> void:
	_jugar.pressed.connect(_abrir_controles.bind(_jugar))
	_boton_controles.pressed.connect(_abrir_controles.bind(_boton_controles))
	_controles.empezar.connect(_on_controles_empezar)
	_controles.cerrado.connect(_on_controles_cerrado)
	_jugar.grab_focus()


func _abrir_controles(boton: Button) -> void:
	_boton_que_abrio = boton
	_opciones.visible = false
	_controles.abrir(boton == _jugar)


func _on_controles_empezar() -> void:
	get_tree().change_scene_to_file(escena_partida)


func _on_controles_cerrado() -> void:
	_opciones.visible = true
	_boton_que_abrio.grab_focus()
