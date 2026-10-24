extends Resource
class_name Sonido

@export var audio: AudioStream
@export_range(-40, 12, 0.5, "suffix:dB") var volumen := 0.0
@export_range(1, 8, 1) var copias := 3
@export_enum("Efectos", "UI") var bus := "Efectos"
