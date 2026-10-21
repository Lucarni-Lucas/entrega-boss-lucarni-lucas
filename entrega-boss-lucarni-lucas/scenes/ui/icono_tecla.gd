class_name IconoTecla
extends Control

enum Estado { NORMAL, APAGADA, SIGUIENTE, HECHA }

@export var textura: Texture2D:
	set(valor):
		textura = valor
		update_minimum_size()
		queue_redraw()
@export_range(0.05, 2, 0.01) var escala := 0.45:
	set(valor):
		escala = valor
		update_minimum_size()
		queue_redraw()
@export var accion: StringName
@export var color_apagado := Color(0.5, 0.5, 0.5)
@export_group("Apretado")
@export_range(0, 20, 1, "suffix:px") var bajada_apretado := 5.0
@export_range(0.5, 1, 0.01) var escala_apretado := 0.9
@export_range(0, 1, 0.05) var brillo_apretado := 0.75
@export_range(0, 0.5, 0.01, "suffix:s") var duracion_bajar := 0.05
@export_range(0, 0.5, 0.01, "suffix:s") var duracion_subir := 0.14
@export_group("Resaltado")
@export_range(1, 2, 0.01) var escala_latido := 1.12
@export_range(0.1, 3, 0.05, "suffix:s") var periodo_latido := 1.0
@export_range(1, 2, 0.01) var escala_encendido := 1.35
@export_range(0, 1, 0.01, "suffix:s") var duracion_encendido := 0.2

var esquema: EsquemaInput.Esquema

var _estado := Estado.NORMAL
var _tween_estado: Tween
var _tween_apretado: Tween
var _apretado := 0.0:
	set(valor):
		_apretado = valor
		queue_redraw()
var _escala_estado := 1.0:
	set(valor):
		_escala_estado = valor
		queue_redraw()


func _input(event: InputEvent) -> void:
	if accion.is_empty() or not is_visible_in_tree():
		return
	if event.is_action_pressed(accion) and EsquemaInput.esquema_de(event) == esquema:
		apretar()


func _get_minimum_size() -> Vector2:
	return textura.get_size() * escala if textura else Vector2.ZERO


func _draw() -> void:
	if textura == null:
		return
	var tamano := textura.get_size() * escala
	var brillo := lerpf(1.0, brillo_apretado, _apretado)
	draw_set_transform(size / 2 + Vector2(0, bajada_apretado * _apretado), 0.0, Vector2.ONE * _escala_estado * lerpf(1.0, escala_apretado, _apretado))
	draw_texture_rect(textura, Rect2(-tamano / 2, tamano), false, Color(brillo, brillo, brillo))


func apretar() -> void:
	if _tween_apretado:
		_tween_apretado.kill()
	_tween_apretado = create_tween()
	_tween_apretado.tween_property(self, "_apretado", 1.0, duracion_bajar)
	_tween_apretado.tween_property(self, "_apretado", 0.0, duracion_subir).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


func mostrar(estado: Estado) -> void:
	if estado == _estado:
		return
	_estado = estado
	if _tween_estado:
		_tween_estado.kill()
	_escala_estado = 1.0
	modulate = color_apagado if estado == Estado.APAGADA else Color.WHITE
	if estado == Estado.SIGUIENTE:
		_tween_estado = create_tween().set_loops().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_tween_estado.tween_property(self, "_escala_estado", escala_latido, periodo_latido / 2)
		_tween_estado.tween_property(self, "_escala_estado", 1.0, periodo_latido / 2)
	elif estado == Estado.HECHA:
		_escala_estado = escala_encendido
		_tween_estado = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		_tween_estado.tween_property(self, "_escala_estado", 1.0, duracion_encendido)
