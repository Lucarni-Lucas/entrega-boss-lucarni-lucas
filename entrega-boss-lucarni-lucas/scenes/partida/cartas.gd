extends Node
class_name Cartas

signal carta_aplicada(carta: Carta)

@export var jugador: Player
@export var pozo: Array[Carta] = []

var tomadas: Array[Carta] = []


func aplicar(carta: Carta) -> void:
	for nombre in carta.cambios:
		_sumar(nombre, carta.cambios[nombre])
	if carta.efecto:
		var efecto: EfectoCarta = carta.efecto.instantiate()
		efecto.jugador = jugador
		jugador.add_child(efecto)
	tomadas.append(carta)
	carta_aplicada.emit(carta)


func ofrecer(cantidad: int) -> Array[Carta]:
	var disponibles: Array[Carta] = []
	disponibles.assign(pozo.filter(func(carta: Carta) -> bool: return not carta in tomadas))
	disponibles.shuffle()
	return disponibles.slice(0, cantidad)


func _sumar(nombre: StringName, cantidad: float) -> void:
	if not nombre in jugador.params:
		push_error("La carta toca un param que no existe en PlayerParams: %s" % nombre)
		return
	var actual: Variant = jugador.params.get(nombre)
	jugador.params.set(nombre, actual + (roundi(cantidad) if actual is int else cantidad))
