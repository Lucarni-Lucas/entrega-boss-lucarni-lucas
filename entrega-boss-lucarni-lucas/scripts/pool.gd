extends RefCounted
class_name Pool

var _escena: PackedScene
var _contenedor: Node
var _al_crear: Callable
var _libres: Array[Node] = []
## Los nodos que maneja tienen que implementar desactivar().


func _init(escena: PackedScene, contenedor: Node, al_crear: Callable) -> void:
	_escena = escena
	_contenedor = contenedor
	_al_crear = al_crear


func precalentar(cantidad: int) -> void:
	for i in cantidad:
		_libres.append(_crear())


func tomar() -> Node:
	if _libres.is_empty():
		return _crear()
	return _libres.pop_back()


func devolver(nodo: Node) -> void:
	nodo.desactivar()
	_libres.append(nodo)


func _crear() -> Node:
	var nodo := _escena.instantiate()
	_contenedor.add_child(nodo)
	_al_crear.call(nodo)
	nodo.desactivar()
	return nodo
