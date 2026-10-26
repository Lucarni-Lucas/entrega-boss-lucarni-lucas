extends Node2D

@export var color_relleno := Color("5ec8f0")
@export var color_borde := Color("202024")
@export var color_brillo := Color("e8f8ff")
@export_range(0, 100, 0.5, "suffix:px") var radio := 9.0
@export_range(0, 10, 0.5, "suffix:px") var ancho_borde := 3.0


func _draw() -> void:
	draw_circle(Vector2.ZERO, radio, color_borde)
	draw_circle(Vector2.ZERO, radio - ancho_borde, color_relleno)
	draw_circle(Vector2(-radio, -radio) * 0.3, radio * 0.25, color_brillo)
