extends Node

const _SHADERS: Array[Shader] = [
	preload("res://scenes/eventos/zona_lava.gdshader"),
	preload("res://scenes/eventos/ceguera.gdshader"),
	preload("res://scenes/efectos/anillo.gdshader"),
	preload("res://scenes/enemigos/destello.gdshader"),
	preload("res://scenes/player/fatiga.gdshader"),
]


func _ready() -> void:
	for shader in _SHADERS:
		var material := ShaderMaterial.new()
		material.shader = shader
		var punto := ColorRect.new()
		punto.size = Vector2.ONE
		punto.material = material
		add_child(punto)
	await RenderingServer.frame_post_draw
	for punto in get_children():
		punto.queue_free()
