extends Node2D

@export var ronda_params: RondaParams

@onready var _nebulosa: TextureRect = $Nebulosa/Imagen


func _on_ronda_empezo(numero: int, _total: int) -> void:
	var fondo := ronda_params.guion(numero).fondo
	if fondo != null:
		_nebulosa.texture = fondo
