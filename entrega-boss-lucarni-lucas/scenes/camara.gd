extends Camera2D

@export var objetivo: Node2D


func _ready() -> void:
	if objetivo == null:
		return
	
	global_position = objetivo.global_position
	reset_smoothing()


func _physics_process(_delta: float) -> void:
	if objetivo == null:
		return
	global_position = objetivo.global_position
