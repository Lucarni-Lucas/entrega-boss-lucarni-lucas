extends Control

@export_file("*.tscn") var escena_partida: String

@onready var _jugar: Button = $Opciones/Jugar


func _ready() -> void:
	_jugar.pressed.connect(_on_jugar_pressed)
	_jugar.grab_focus()


func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file(escena_partida)
