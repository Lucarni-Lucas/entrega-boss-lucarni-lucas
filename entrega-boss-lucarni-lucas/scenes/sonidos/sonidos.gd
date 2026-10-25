extends Node

@export var libreria: LibreriaSonidos
@export var musica: AudioStream
@export_range(-40, 0, 0.5, "suffix:dB") var volumen_musica := 0.0
@export var temas_ronda: Array[AudioStream] = []
@export var ronda_params: RondaParams
@export_range(100, 5000, 50, "suffix:Hz") var corte_tapado := 800.0
@export_range(0, 2, 0.05, "suffix:s") var duracion_tapado := 0.3
@export var jugador: Player


func _ready() -> void:
	if musica:
		Audio.tocar_musica(musica, volumen_musica)


func _exit_tree() -> void:
	Audio.parar(libreria.boomerang_gira)
	_tapar_musica(false)


func _tapar_musica(tapar: bool) -> void:
	Audio.tapar_musica(tapar, corte_tapado, duracion_tapado)


func _on_jugador_salto() -> void:
	Audio.tocar(libreria.salto)


func _on_jugador_aterrizo() -> void:
	if jugador.estado_actual() != Player.Estado.GROUND_POUND:
		Audio.tocar(libreria.aterrizaje)


func _on_jugador_reboto() -> void:
	Audio.tocar(libreria.rebote)


func _on_jugador_slasheo() -> void:
	Audio.tocar(libreria.slash)


func _on_jugador_dive() -> void:
	Audio.tocar(libreria.dive)


func _on_jugador_anticipo_gp() -> void:
	Audio.tocar(libreria.gp_anticipo)


func _on_jugador_impacto_gp(_posicion: Vector2, _radio: float) -> void:
	Audio.tocar(libreria.gp_impacto)


func _on_jugador_lanzo_boomerang() -> void:
	Audio.tocar(libreria.boomerang_lanzar)
	Audio.tocar(libreria.boomerang_gira)


func _on_jugador_atrapo_boomerang() -> void:
	Audio.parar(libreria.boomerang_gira)
	Audio.tocar(libreria.boomerang_atrapado)


func _on_jugador_golpeado() -> void:
	Audio.tocar(libreria.herido)


func _on_jugador_curado() -> void:
	Audio.tocar(libreria.curacion)


func _on_jugador_fuerza_gp_recuperada() -> void:
	Audio.tocar(libreria.energia_gp)


func _on_jugador_murio() -> void:
	Audio.parar(libreria.boomerang_gira)
	Audio.tocar(libreria.muerte_jugador)


func _on_spawner_enemigo_golpeado(_posicion: Vector2, origen: Hitbox.Origen) -> void:
	Audio.tocar(libreria.slash_pega if origen == Hitbox.Origen.SLASH else libreria.enemigo_golpeado)


func _on_spawner_enemigo_aparecio(enemigo: Enemigo) -> void:
	if not enemigo.murio.is_connected(_on_enemigo_murio):
		enemigo.murio.connect(_on_enemigo_murio.bind(enemigo))


func _on_enemigo_murio(_posicion: Vector2, _origen: Hitbox.Origen, enemigo: Enemigo) -> void:
	Audio.tocar(libreria.muerte_fantasma if enemigo.params.altura_vuelo > 0.0 else libreria.muerte_esqueleto)


func _on_cuenta_regresiva_numero_cambio(_valor: int) -> void:
	Audio.tocar(libreria.cuenta)


func _on_cuenta_regresiva_terminada() -> void:
	Audio.tocar(libreria.ya)


func _on_partida_ronda_empezo(numero: int, _total: int) -> void:
	_tapar_musica(false)
	var fija := ronda_params.guion(numero).musica if ronda_params else null
	if fija:
		Audio.tocar_musica(fija, volumen_musica)
		return
	var opciones := temas_ronda.filter(func(tema: AudioStream) -> bool: return tema != Audio.tema_actual())
	if not opciones.is_empty():
		Audio.tocar_musica(opciones.pick_random(), volumen_musica)


func _on_partida_ronda_superada(_numero: int, _total: int) -> void:
	_tapar_musica(true)
	Audio.tocar(libreria.jingle_ronda)


func _on_partida_finalizo(gano: bool) -> void:
	_tapar_musica(true)
	Audio.parar(libreria.boomerang_gira)
	Audio.tocar(libreria.jingle_victoria if gano else libreria.jingle_derrota)


func _on_menu_partida_pauso() -> void:
	_tapar_musica(true)
	Audio.tocar(libreria.pausa)


func _on_menu_partida_reanudo() -> void:
	_tapar_musica(false)
	Audio.tocar(libreria.reanudar)
