extends Node

@export var libreria: LibreriaSonidos
@export var musica: AudioStream
@export_range(-40, 0, 0.5, "suffix:dB") var volumen_musica := 0.0
@export var jugador: Player


func _ready() -> void:
	if musica:
		Audio.tocar_musica(musica, volumen_musica)


func _exit_tree() -> void:
	Audio.parar(libreria.boomerang_gira)


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


func _on_partida_ronda_superada(_numero: int, _total: int) -> void:
	Audio.tocar(libreria.jingle_ronda)


func _on_partida_finalizo(gano: bool) -> void:
	Audio.parar(libreria.boomerang_gira)
	Audio.tocar(libreria.jingle_victoria if gano else libreria.jingle_derrota)


func _on_menu_partida_pauso() -> void:
	Audio.tocar(libreria.pausa)


func _on_menu_partida_reanudo() -> void:
	Audio.tocar(libreria.reanudar)
