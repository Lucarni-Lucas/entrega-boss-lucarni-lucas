@abstract
extends Node2D
class_name VerboExclusivo


@abstract
func estado() -> Player.Estado


@abstract
func estados_validos() -> Array


@abstract
func activar(player: Player) -> void


@abstract
func procesar_fisica(player: Player, delta: float) -> void


func cancelar(_player: Player) -> void:
	pass


func esta_disponible(_player: Player) -> bool:
	return true


func puede_interrumpir(_otro: VerboExclusivo) -> bool:
	return false
