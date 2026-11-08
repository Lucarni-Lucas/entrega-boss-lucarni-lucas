extends Node2D
class_name Plata

signal cambio(cantidad: int)
signal juntada

@export var jugador: Player
@export var textura: Texture2D
@export var iniciales := 25
@export var valor_moneda := 1
@export_range(0, 1, 0.05) var cobro_restante := 0.5
@export_range(0, 400, 1, "suffix:px") var radio_recogida := 90.0
@export_range(0, 3000, 10, "suffix:px/s") var velocidad_iman_lejos := 500.0
@export_range(0, 3000, 10, "suffix:px/s") var velocidad_iman_cerca := 1400.0

var cantidad := 0
var _monedas := PackedVector2Array()
var _atraidas := PackedVector2Array()
var _capa_atraidas := Node2D.new()


func _ready() -> void:
	add_child(_capa_atraidas)
	_capa_atraidas.draw.connect(_dibujar_atraidas)
	_sumar.call_deferred(iniciales)


func _physics_process(delta: float) -> void:
	if jugador.esta_en_suelo():
		_atraer()
	if not _atraidas.is_empty():
		_mover_atraidas(delta)


func _atraer() -> void:
	var centro := jugador.global_position
	var escala := Vector2(1.0, 1.0 / jugador.params.anim_perspectiva)
	var limite := radio_recogida * radio_recogida
	var cantidad_antes := _monedas.size()
	for i in range(cantidad_antes - 1, -1, -1):
		if ((_monedas[i] - centro) * escala).length_squared() <= limite:
			_atraidas.append(_monedas[i])
			_monedas.remove_at(i)
	if _monedas.size() != cantidad_antes:
		queue_redraw()


func _mover_atraidas(delta: float) -> void:
	var centro := jugador.global_position
	var juntadas := 0
	for i in range(_atraidas.size() - 1, -1, -1):
		var distancia := _atraidas[i].distance_to(centro)
		var lejania := clampf(distancia / maxf(radio_recogida, 1.0), 0.0, 1.0)
		var paso := lerpf(velocidad_iman_cerca, velocidad_iman_lejos, lejania) * delta
		if paso >= distancia:
			_atraidas.remove_at(i)
			juntadas += 1
		else:
			_atraidas[i] = _atraidas[i].move_toward(centro, paso)
	_capa_atraidas.queue_redraw()
	if juntadas > 0:
		_sumar(juntadas * valor_moneda)
		juntada.emit()


func _draw() -> void:
	_dibujar_en(self, _monedas)


func _dibujar_atraidas() -> void:
	_dibujar_en(_capa_atraidas, _atraidas)


func _dibujar_en(capa: Node2D, monedas: PackedVector2Array) -> void:
	var mitad := textura.get_size() * 0.5
	for moneda in monedas:
		capa.draw_texture(textura, moneda - mitad)


func alcanza(precio: int) -> bool:
	return cantidad >= precio


func gastar(precio: int) -> bool:
	if not alcanza(precio):
		return false
	_sumar(-precio)
	return true


func cobrar_restante(_numero: int) -> void:
	_sumar((_atraidas.size() * valor_moneda) + ceili(_monedas.size() * valor_moneda * cobro_restante))
	_monedas.clear()
	_atraidas.clear()
	queue_redraw()
	_capa_atraidas.queue_redraw()


func _on_spawner_enemigo_murio(posicion: Vector2, _origen: Hitbox.Origen) -> void:
	_monedas.append(posicion)
	queue_redraw()


func _sumar(valor: int) -> void:
	cantidad += valor
	cambio.emit(cantidad)
