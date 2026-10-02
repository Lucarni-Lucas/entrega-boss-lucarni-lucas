extends CanvasLayer

@export_range(0, 1, 0.05, "suffix:s") var duracion_entrada := 0.2
@export_file("*.tscn") var escena_menu: String

@onready var _contenido: Control = $Contenido
@onready var _titulo: Label = $Contenido/Opciones/Titulo
@onready var _reintentar: Button = $Contenido/Opciones/Reintentar
@onready var _menu_principal: Button = $Contenido/Opciones/MenuPrincipal


func _ready() -> void:
	_reintentar.pressed.connect(_on_reintentar_pressed)
	_menu_principal.pressed.connect(_on_menu_principal_pressed)


func _on_partida_finalizo(gano: bool) -> void:
	_titulo.text = "¡GANASTE!" if gano else "MORISTE"
	visible = true
	_contenido.modulate.a = 0.0
	create_tween().tween_property(_contenido, "modulate:a", 1.0, duracion_entrada)
	_reintentar.grab_focus()


func _on_reintentar_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_menu_principal_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(escena_menu)
