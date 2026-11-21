extends EfectoCarta

@export var escena_onda: PackedScene
@export var ondas := 4
@export var tinte := Color("8fb0ea")
@export_range(0, 1, 0.05) var tinte_minimo := 0.35

var _ondas: Array[OndaFreno] = []
var _spawner: Spawner


func _ready() -> void:
	for i in ondas:
		var onda: OndaFreno = escena_onda.instantiate()
		add_child(onda)
		_ondas.append(onda)
	_spawner = get_tree().get_first_node_in_group(Spawner.GRUPO) as Spawner
	_ondas[0].precalentar(jugador.global_position)
	jugador.combo_termino.connect(_on_combo_termino)
	jugador.volvio_al_inicio.connect(_apagar_ondas)


func freno_para(combo: int) -> float:
	var params := jugador.params
	var rango := float(params.freno_combo_max - params.freno_combo_min)
	var t := clampf((combo - params.freno_combo_min) / rango, 0.0, 1.0)
	var inicio := params.freno_min + params.freno_paso_inicial * rango / 3.0
	var final := params.freno_max - params.freno_paso_final * rango / 3.0
	return bezier_interpolate(params.freno_min, inicio, final, params.freno_max, t)


func ondas_activas() -> Array[OndaFreno]:
	var activas: Array[OndaFreno] = []
	activas.assign(_ondas.filter(func(onda: OndaFreno) -> bool: return onda.activa()))
	return activas


func _on_combo_termino(combo: int) -> void:
	if combo < jugador.params.freno_combo_min or _spawner == null:
		return
	var onda: OndaFreno = _ondas.pop_front()
	_ondas.push_back(onda)
	onda.lanzar(jugador.global_position, jugador.params.anim_perspectiva, _spawner.enemigos_activos(), _frenar.bind(freno_para(combo)))
	Audio.tocar(Audio.libreria.tiempo_muerto)


func _frenar(enemigo: Enemigo, freno: float) -> void:
	var params := jugador.params
	if enemigo is Jefe:
		freno *= params.freno_jefe
	var intensidad := lerpf(tinte_minimo, 1.0, clampf(inverse_lerp(params.freno_min, params.freno_max, freno), 0.0, 1.0))
	enemigo.ralentizar(1.0 - freno, params.freno_duracion, Color.WHITE.lerp(tinte, intensidad))


func _apagar_ondas() -> void:
	for onda in _ondas:
		onda.apagar()
