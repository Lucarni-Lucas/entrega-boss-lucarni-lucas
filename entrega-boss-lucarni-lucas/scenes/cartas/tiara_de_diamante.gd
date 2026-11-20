extends EfectoCarta

var _espera := 0.0

@onready var _tiara: Tiara = $Tiara


func _ready() -> void:
	_tiara.jugador = jugador
	jugador.golpe_bloqueado.connect(_on_golpe_bloqueado)
	jugador.volvio_al_inicio.connect(_reiniciar)
	jugador.poner_escudo(true)


func _physics_process(delta: float) -> void:
	if _espera <= 0.0:
		return
	_espera -= delta
	if _espera <= 0.0:
		jugador.poner_escudo(true)
		_tiara.volver()
		Audio.tocar(Audio.libreria.tiara_lista)


func _on_golpe_bloqueado() -> void:
	_espera = jugador.params.tiara_recarga
	_tiara.romper()
	Audio.tocar(Audio.libreria.tiara_rota)


func _reiniciar() -> void:
	_espera = 0.0
	_tiara.desactivar()
	jugador.poner_escudo(true)
