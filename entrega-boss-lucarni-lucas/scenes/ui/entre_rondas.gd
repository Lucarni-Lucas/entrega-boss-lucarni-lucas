extends CanvasLayer

signal comenzar

@export var params: RondaParams
@export_range(0, 1, 0.05, "suffix:s") var duracion_entrada := 0.2
@export_range(0, 1, 0.05) var alpha_bloqueado := 0.35

var _bloqueado := false

@onready var _contenido: Control = $Contenido
@onready var _titulo: Label = $Contenido/Opciones/Titulo
@onready var _detalle: Label = $Contenido/Opciones/Detalle
@onready var _comenzar: Button = $Contenido/Opciones/Comenzar


func _ready() -> void:
	_comenzar.pressed.connect(_on_comenzar_pressed)


func _input(_event: InputEvent) -> void:
	if _bloqueado:
		get_viewport().set_input_as_handled()


func mostrar(numero: int, total: int) -> void:
	var quedan := total - numero
	_titulo.text = "¡RONDA %d COMPLETA!" % numero
	_detalle.text = "Te queda 1 ronda" if quedan == 1 else "Te quedan %d rondas" % quedan
	_comenzar.poner_texto("Comenzar ronda %d" % (numero + 1))
	visible = true
	_contenido.modulate.a = 0.0
	create_tween().tween_property(_contenido, "modulate:a", 1.0, duracion_entrada)
	_bloquear()


func _bloquear() -> void:
	_bloqueado = true
	_comenzar.modulate.a = alpha_bloqueado
	await get_tree().create_timer(params.bloqueo_final).timeout
	_bloqueado = false
	_comenzar.modulate.a = 1.0
	_comenzar.grab_focus()


func _on_comenzar_pressed() -> void:
	visible = false
	comenzar.emit()
