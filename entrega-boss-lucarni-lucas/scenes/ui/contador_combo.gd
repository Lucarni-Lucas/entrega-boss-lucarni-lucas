extends Control

@export var llamas: Array[Texture2D] = []
@export var niveles := PackedInt32Array([2, 5, 10, 25, 50])
@export var maximo := 999
@export_range(0.3, 1, 0.01) var tamano_llama_minimo := 0.8
@export_range(0.3, 2, 0.01) var proporcion_llama := 0.95
@export var balanceo := PackedFloat32Array([-8.0, 6.0, -3.0, 0.0])
@export_range(0, 1, 0.01, "suffix:s") var duracion_balanceo := 0.25
@export_range(1, 2, 0.01) var agrandado_numero := 1.18
@export_range(1, 2, 0.01) var estallido_llama := 1.3
@export_range(0, 1, 0.01, "suffix:s") var duracion_estallido := 0.25
@export_range(0, 1, 0.01, "suffix:s") var duracion_entrada := 0.18
@export_range(1, 2, 0.01) var agrandado_salida := 1.15
@export_range(0, 2, 0.05, "suffix:s") var duracion_salida := 0.5
@export_range(0, 0.2, 0.005) var titileo := 0.04
@export_range(0, 40, 0.5, "suffix:Hz") var titileo_velocidad := 6.0

var combo := 0
var nivel := -1
var _jugador: Player
var _tiempo := 0.0
var _escala_llama := 1.0
var _golpe_llama := 1.0
var _tween_numero: Tween
var _tween_giro: Tween
var _tween_llama: Tween
var _tween_caja: Tween

@onready var _llama: TextureRect = $Llama
@onready var _numero: Label = $Numero


func _ready() -> void:
	visible = false
	pivot_offset = size / 2.0
	_llama.size = Vector2(size.y * proporcion_llama, size.y) / (1.0 + titileo)
	_llama.position = (size - _llama.size) / 2.0
	_llama.pivot_offset = _llama.size / 2.0
	_numero.pivot_offset = _numero.size / 2.0
	_conectar.call_deferred()


func _conectar() -> void:
	_jugador = get_tree().get_first_node_in_group(Player.GRUPO) as Player
	if _jugador == null:
		return
	_jugador.combo_subio.connect(_on_combo_subio)
	_jugador.combo_termino.connect(_terminar.unbind(1))
	_jugador.volvio_al_inicio.connect(reiniciar)


func _process(delta: float) -> void:
	if not visible:
		return
	_tiempo += delta
	var onda := sin(_tiempo * TAU * titileo_velocidad) * titileo
	_llama.scale = Vector2(1.0 - onda * 0.5, 1.0 + onda) * _escala_llama * _golpe_llama


func _on_combo_subio(valor: int) -> void:
	combo = mini(valor, maximo)
	if combo < niveles[0]:
		return
	if combo == niveles[0]:
		_entrar()
	_numero.text = "x%d" % combo
	_balancear()
	var nuevo := _nivel_de(combo)
	if nuevo != nivel:
		_cambiar_nivel(nuevo, combo != niveles[0])


func _nivel_de(valor: int) -> int:
	var resultado := 0
	for i in niveles.size():
		if valor >= niveles[i]:
			resultado = i
	return resultado


func _entrar() -> void:
	if _tween_caja:
		_tween_caja.kill()
	visible = true
	modulate.a = 1.0
	scale = Vector2.ZERO
	_tween_caja = create_tween()
	_tween_caja.tween_property(self, "scale", Vector2.ONE, duracion_entrada).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _balancear() -> void:
	for tween in [_tween_numero, _tween_giro]:
		if tween:
			tween.kill()
	_numero.scale = Vector2.ONE * agrandado_numero
	_numero.rotation_degrees = 0.0
	_tween_numero = create_tween()
	_tween_numero.tween_property(_numero, "scale", Vector2.ONE, duracion_balanceo)
	var paso := duracion_balanceo / maxf(balanceo.size(), 1)
	_tween_giro = create_tween()
	for angulo in balanceo:
		_tween_giro.tween_property(_numero, "rotation_degrees", angulo, paso)


func _cambiar_nivel(nuevo: int, con_estallido: bool) -> void:
	nivel = nuevo
	_llama.texture = llamas[mini(nuevo, llamas.size() - 1)]
	_escala_llama = lerpf(tamano_llama_minimo, 1.0, float(nuevo) / maxf(niveles.size() - 1, 1))
	if _tween_llama:
		_tween_llama.kill()
	_golpe_llama = 1.0
	if not con_estallido:
		return
	_golpe_llama = estallido_llama
	_tween_llama = create_tween()
	_tween_llama.tween_property(self, "_golpe_llama", 1.0, duracion_estallido).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _terminar() -> void:
	combo = 0
	nivel = -1
	if not visible:
		return
	if _tween_caja:
		_tween_caja.kill()
	_tween_caja = create_tween()
	_tween_caja.tween_property(self, "scale", Vector2.ONE * agrandado_salida, duracion_salida * 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween_caja.tween_property(self, "modulate:a", 0.0, duracion_salida * 0.75)
	_tween_caja.tween_callback(hide)


func reiniciar() -> void:
	combo = 0
	nivel = -1
	for tween in [_tween_caja, _tween_numero, _tween_giro, _tween_llama]:
		if tween:
			tween.kill()
	_numero.rotation_degrees = 0.0
	_numero.scale = Vector2.ONE
	visible = false
