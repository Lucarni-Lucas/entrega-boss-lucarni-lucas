extends Node

const SILENCIO := -40.0
const BUSES: Array[StringName] = [&"Master", &"Musica", &"Efectos", &"UI"]
const _ARCHIVO_AJUSTES := "user://ajustes.cfg"

var _reproductores: Dictionary[Sonido, AudioStreamPlayer] = {}
var _musica_actual: AudioStreamPlayer
var _musica_otra: AudioStreamPlayer
var _fundidos: Dictionary[AudioStreamPlayer, Tween] = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_musica_actual = _crear_reproductor_musica()
	_musica_otra = _crear_reproductor_musica()
	_cargar_volumenes()


func tocar(sonido: Sonido) -> void:
	if sonido == null or sonido.audio == null:
		return
	_reproductor_de(sonido).play()


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
		reproductor.max_polyphony = sonido.copias
		reproductor.bus = sonido.bus
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
