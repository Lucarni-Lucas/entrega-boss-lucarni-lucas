@tool
extends Resource
class_name GuionRonda

@export var grupos: Array[GrupoSpawn] = []:
	set(valor):
		grupos = valor
		for i in grupos.size():
			if grupos[i] == null:
				grupos[i] = GrupoSpawn.new()
@export var fondo: Texture2D


static func con_grupo_inicial() -> GuionRonda:
	var guion := GuionRonda.new()
	guion.grupos = [GrupoSpawn.new()]
	return guion
