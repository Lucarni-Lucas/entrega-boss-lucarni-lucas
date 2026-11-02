@tool
extends Resource
class_name GuionRonda

@export var grupos: Array[GrupoSpawn] = []:
	set(valor):
		grupos = valor
		for i in grupos.size():
			if grupos[i] == null:
				grupos[i] = GrupoSpawn.new()
@export_range(0, 20, 1) var dano_contacto: int = 5
@export var fondo: Texture2D
@export var musica: AudioStream


static func con_grupo_inicial() -> GuionRonda:
	var guion := GuionRonda.new()
	guion.grupos = [GrupoSpawn.new()]
	return guion
