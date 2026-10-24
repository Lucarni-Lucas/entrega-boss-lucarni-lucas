extends Node

const SILENCIO := -40.0
const BUSES: Array[StringName] = [&"Master", &"Musica", &"Efectos", &"UI"]
const _ARCHIVO_AJUSTES := "user://ajustes.cfg"
const _NAVEGACION: Array[StringName] = [&"ui_up", &"ui_down", &"ui_left", &"ui_right", &"ui_focus_next", &"ui_focus_prev"]

var libreria: LibreriaSonidos = preload("res://resources/audio/libreria_sonidos.tres")

var _reproductores: Dictionary[Sonido, AudioStreamPlayer] = {}
var _musica_actual: AudioStreamPlayer
var _musica_otra: AudioStreamPlayer
var _fundidos: Dictionary[AudioStreamPlayer, Tween] = {}
var _cuadro_navegacion := -10


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_musica_actual = _crear_reproductor_musica()
	_musica_otra = _crear_reproductor_musica()
	_cargar_volumenes()
	get_tree().node_added.connect(_on_nodo_agregado)
	for boton in get_tree().root.find_children("*", "BaseButton", true, false):
		_on_nodo_agregado(boton)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or _NAVEGACION.any(func(accion: StringName) -> bool: return event.is_action_pressed(accion, true)):
		_cuadro_navegacion = Engine.get_process_frames()


func tocar(sonido: Sonido) -> void:
	if sonido == null or sonido.audio == null:
		return
	_reproductor_de(sonido).play()


func parar(sonido: Sonido) -> void:
	if _reproductores.has(sonido):
		_reproductores[sonido].stop()


func tocar_musica(tema: AudioStream, volumen := 0.0, fundido := 1.0) -> void:
	if _musica_actual.stream == tema and _musica_actual.playing:
		return
	_soltar_actual(fundido)
	_musica_actual.stream = tema
	_musica_actual.volume_db = SILENCIO
	_musica_actual.play()
	_fundir(_musica_actual, volumen, fundido)


func parar_musica(fundido := 1.0) -> void:
	_soltar_actual(fundido)


func volumen_bus(bus: StringName) -> float:
	return AudioServer.get_bus_volume_linear(AudioServer.get_bus_index(bus))


func poner_volumen_bus(bus: StringName, valor: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index(bus), valor)


func guardar_volumenes() -> void:
	var config := ConfigFile.new()
	for bus in BUSES:
		config.set_value("volumen", bus, volumen_bus(bus))
	config.save(_ARCHIVO_AJUSTES)


func _reproductor_de(sonido: Sonido) -> AudioStreamPlayer:
	if not _reproductores.has(sonido):
		var reproductor := AudioStreamPlayer.new()
		reproductor.stream = sonido.audio
		reproductor.volume_db = sonido.volumen
		reproductor.pitch_scale = sonido.tono
		reproductor.max_polyphony = sonido.copias
		reproductor.bus = sonido.bus
		reproductor.process_mode = Node.PROCESS_MODE_PAUSABLE if sonido.bus == "Efectos" else Node.PROCESS_MODE_ALWAYS
		add_child(reproductor)
		_reproductores[sonido] = reproductor
	return _reproductores[sonido]


func _soltar_actual(fundido: float) -> void:
	_fundir(_musica_actual, SILENCIO, fundido)
	var saliente := _musica_actual
	_musica_actual = _musica_otra
	_musica_otra = saliente


func _crear_reproductor_musica() -> AudioStreamPlayer:
	var reproductor := AudioStreamPlayer.new()
	reproductor.bus = &"Musica"
	reproductor.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	add_child(reproductor)
	return reproductor


func _fundir(reproductor: AudioStreamPlayer, destino: float, duracion: float) -> void:
	if _fundidos.has(reproductor):
		_fundidos[reproductor].kill()
	var tween := create_tween()
	tween.tween_property(reproductor, "volume_db", destino, duracion)
	if destino <= SILENCIO:
		tween.tween_callback(reproductor.stop)
	_fundidos[reproductor] = tween


func _cargar_volumenes() -> void:
	var config := ConfigFile.new()
	if config.load(_ARCHIVO_AJUSTES) != OK:
		return
	for bus in BUSES:
		poner_volumen_bus(bus, config.get_value("volumen", bus, 1.0))


func _on_nodo_agregado(nodo: Node) -> void:
	if nodo is not BaseButton or nodo.focus_entered.is_connected(_on_boton_enfocado):
		return
	nodo.focus_entered.connect(_on_boton_enfocado)
	if not nodo.is_in_group(&"sonido_propio"):
		nodo.pressed.connect(tocar.bind(libreria.ui_aceptar))


func _on_boton_enfocado() -> void:
	if Engine.get_process_frames() - _cuadro_navegacion <= 1:
		tocar(libreria.ui_foco)
