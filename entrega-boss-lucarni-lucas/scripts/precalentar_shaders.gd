extends Node

const _SHADERS: Array[Shader] = [
	preload("res://scenes/eventos/zona_lava.gdshader"),
	preload("res://scenes/eventos/ceguera.gdshader"),
	preload("res://scenes/efectos/anillo.gdshader"),
	preload("res://scenes/enemigos/destello.gdshader"),
	preload("res://scenes/player/fatiga.gdshader"),
	preload("res://scenes/cartas/rompe_pisos.gdshader"),
	preload("res://scenes/cartas/espejismo_aereo.gdshader"),
]


func _ready() -> void:
	for shader in _SHADERS:
		var material := ShaderMaterial.new()
		material.shader = shader
		var punto := ColorRect.new()
		punto.size = Vector2.ONE
		punto.material = material
		add_child(punto)
	var recorte := ColorRect.new()
	recorte.size = Vector2.ONE
	recorte.clip_children = CanvasItem.CLIP_CHILDREN_AND_DRAW
	recorte.material = ShaderMaterial.new()
	recorte.material.shader = preload("res://scenes/enemigos/destello.gdshader")
	var adentro := ColorRect.new()
	adentro.size = Vector2.ONE
	adentro.use_parent_material = true
	recorte.add_child(adentro)
	add_child(recorte)
	await RenderingServer.frame_post_draw
	for punto in get_children():
		punto.queue_free()
