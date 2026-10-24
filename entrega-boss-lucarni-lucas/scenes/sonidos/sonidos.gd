extends Node

@export var libreria: LibreriaSonidos
@export var musica: AudioStream
@export_range(-40, 0, 0.5, "suffix:dB") var volumen_musica := 0.0


func _ready() -> void:
	if musica:
		Audio.tocar_musica(musica, volumen_musica)


func _on_jugador_salto() -> void:
	Audio.tocar(libreria.salto)


func _on_jugador_aterrizo() -> void:
	Audio.tocar(libreria.aterrizaje)
