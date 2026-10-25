extends Control

@export_file("*.tscn") var escena_tutorial: String
@export_file("*.tscn") var escena_partida: String
@export_range(0.1, 2, 0.05) var velocidad_respiracion := 0.5

@onready var _opciones: VBoxContainer = $Opciones
@onready var _empezar_partida: Button = $Opciones/EmpezarPartida
@onready var _boton_controles: Button = $Opciones/Controles
@onready var _controles := $Controles
@onready var _boton_ajustes: Button = $Opciones/Ajustes
@onready var _ajustes := $Ajustes
@onready var _pregunta: VBoxContainer = $Pregunta
@onready var _hacer_tutorial: Button = $Pregunta/HacerTutorial
@onready var _jugar_directo: Button = $Pregunta/JugarDirecto
@onready var _personajes: Node2D = $Personajes
@onready var _slime: Node2D = $Personajes/Slime


func _ready() -> void:
	_empezar_partida.pressed.connect(_abrir_pregunta)
	_boton_controles.pressed.connect(_abrir_controles)
	_controles.cerrado.connect(_on_controles_cerrado)
	_boton_ajustes.pressed.connect(_abrir_ajustes)
	_ajustes.cerrado.connect(_on_ajustes_cerrado)
	_hacer_tutorial.pressed.connect(_ir_a.bind(escena_tutorial))
	_jugar_directo.pressed.connect(_ir_a.bind(escena_partida))
	_empezar_partida.grab_focus()
	await get_tree().physics_frame
	await get_tree().process_frame
	_congelar_personajes()


func _congelar_personajes() -> void:
	_personajes.process_mode = Node.PROCESS_MODE_DISABLED
	for visual: AnimatedSprite2D in _personajes.find_children("Visual", "AnimatedSprite2D"):
		visual.process_mode = Node.PROCESS_MODE_ALWAYS
		if visual.sprite_frames.has_animation(&"atacar"):
			visual.play(&"atacar")
			visual.speed_scale = velocidad_respiracion


func _unhandled_input(event: InputEvent) -> void:
	if _pregunta.visible and event.is_action_pressed("ui_cancel"):
		_cerrar_pregunta()
		get_viewport().set_input_as_handled()


func _abrir_pregunta() -> void:
	_opciones.visible = false
	_pregunta.visible = true
	_mostrar_enemigos(false)
	_hacer_tutorial.grab_focus()


func _cerrar_pregunta() -> void:
	Audio.tocar(Audio.libreria.ui_volver)
	_pregunta.visible = false
	_opciones.visible = true
	_mostrar_enemigos(true)
	_empezar_partida.grab_focus()


func _mostrar_enemigos(mostrar: bool) -> void:
	for personaje in _personajes.get_children():
		if personaje is Enemigo:
			personaje.visible = mostrar


func _ir_a(escena: String) -> void:
	get_tree().change_scene_to_file(escena)


func _abrir_controles() -> void:
	_opciones.visible = false
	_slime.visible = false
	_controles.abrir()


func _on_controles_cerrado() -> void:
	_opciones.visible = true
	_slime.visible = true
	_boton_controles.grab_focus()


func _abrir_ajustes() -> void:
	_opciones.visible = false
	_slime.visible = false
	_ajustes.abrir()


func _on_ajustes_cerrado() -> void:
	_opciones.visible = true
	_slime.visible = true
	_boton_ajustes.grab_focus()
