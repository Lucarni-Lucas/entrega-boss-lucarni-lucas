@tool
extends Resource
class_name RondaParams

@export_range(1, 20, 1) var cantidad_rondas: int = 5:
	set(valor):
		cantidad_rondas = valor
		_completar_guiones()
@export_range(10, 300, 5, "suffix:s") var duracion: float = 45.0
@export var guiones: Array[GuionRonda] = []:
	set(valor):
		guiones = valor
		_completar_guiones()

@export_group("Cuenta regresiva")
@export var cuenta_desde: int = 3
@export_range(0.1, 2, 0.05, "suffix:s") var cuenta_paso: float = 0.5

@export_group("Pantalla final")
@export_range(0, 3, 0.1, "suffix:s") var bloqueo_final: float = 1.0


func guion(numero: int) -> GuionRonda:
	_completar_guiones()
	return guiones[numero - 1]


func _completar_guiones() -> void:
	var cambio := false
	while guiones.size() < cantidad_rondas:
		guiones.append(null)
	for i in guiones.size():
		if guiones[i] == null:
			guiones[i] = GuionRonda.con_grupo_inicial()
			cambio = true
	if cambio:
		notify_property_list_changed()
