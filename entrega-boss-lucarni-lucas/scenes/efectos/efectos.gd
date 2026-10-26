extends Node2D

@export var params: EfectosParams
@export var jugador: Player
@export var textura_estrella: Texture2D
@export var textura_chispa: Texture2D
@export var tamano_pool_estrellas := 32
@export var tamano_pool_chispas := 128
@export var tamano_pool_anillos := 16

var _estrellas: Array[Sprite2D] = []
var _chispas: Array[Sprite2D] = []
var _anillos: Array[Node2D] = []
var _tweens := {}

@onready var _arriba: Node2D = $Arriba
@onready var _suelo: Node2D = $Suelo
@onready var _anillo: Node2D = $Suelo/Anillo


func _ready() -> void:
	_estrellas = _crear_pool(textura_estrella, _arriba, tamano_pool_estrellas)
	_chispas = _crear_pool(textura_chispa, _arriba, tamano_pool_chispas)
	_anillos.append(_anillo)
	for i in tamano_pool_anillos - 1:
		var anillo: Node2D = _anillo.duplicate()
		_suelo.add_child(anillo)
		_anillos.append(anillo)


func golpe(posicion: Vector2, origen: Hitbox.Origen) -> void:
	if origen != Hitbox.Origen.SLASH:
		return
	var estrella := _tomar(_estrellas)
	estrella.position = posicion
	estrella.rotation = randf() * TAU
	estrella.scale = Vector2.ONE * params.estrella_escala_inicial
	var tween := _animar(estrella)
	tween.tween_property(estrella, "scale", Vector2.ONE * params.estrella_escala_final, params.estrella_crecer)
	tween.tween_property(estrella, "modulate:a", 0.0, params.estrella_desvanecer)
	tween.tween_callback(estrella.hide)
	for i in params.chispas_cantidad:
		var chispa := _tomar(_chispas)
		var direccion := Vector2.from_angle(TAU * (i + randf()) / params.chispas_cantidad)
		chispa.position = posicion
		chispa.scale = Vector2.ONE * params.chispas_escala
		var tween_chispa := _animar(chispa)
		tween_chispa.set_parallel()
		tween_chispa.tween_property(chispa, "position", posicion + direccion * params.chispas_distancia, params.chispas_duracion).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween_chispa.tween_property(chispa, "modulate:a", 0.0, params.chispas_duracion).set_ease(Tween.EASE_IN)
		tween_chispa.chain().tween_callback(chispa.hide)


func _on_jugador_impacto_gp(posicion: Vector2, altura: float, radio: float, _fuerza: float, _primario: bool) -> void:
	var anillo: Node2D = _anillos.pop_front()
	_anillos.push_back(anillo)
	anillo.mostrar(posicion + Vector2(0, -altura), radio, jugador.params.anim_perspectiva, params)


func _crear_pool(textura: Texture2D, contenedor: Node2D, cantidad: int) -> Array[Sprite2D]:
	var pool: Array[Sprite2D] = []
	for i in cantidad:
		var sprite := Sprite2D.new()
		sprite.texture = textura
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		sprite.visible = false
		contenedor.add_child(sprite)
		pool.append(sprite)
	return pool


func _tomar(pool: Array[Sprite2D]) -> Sprite2D:
	var sprite: Sprite2D = pool.pop_front()
	pool.push_back(sprite)
	return sprite


func _animar(sprite: Sprite2D) -> Tween:
	if _tweens.has(sprite):
		_tweens[sprite].kill()
	sprite.modulate.a = 1.0
	sprite.visible = true
	var tween := create_tween()
	_tweens[sprite] = tween
	return tween
