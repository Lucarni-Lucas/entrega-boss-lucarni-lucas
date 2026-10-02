extends RefCounted
class_name Pool

var _escena: PackedScene
var _contenedor: Node
var _al_crear: Callable
var _libres: Array[Node] = []
var _en_uso: Array[Node] = []
## Los nodos que maneja tienen que implementar desactivar().


func _init(escena: PackedScene, contenedor: Node, al_crear: Callable) -> void:
	_escena = escena
	_contenedor = contenedor
	_al_crear = al_crear


func precalentar(cantidad: int) -> void:
	for i in cantidad:
		_libres.append(_crear())


func tomar() -> Node:
	var nodo: Node = _crear() if _libres.is_empty() else _libres.pop_back()
	_en_uso.append(nodo)
	return nodo


func devolver(nodo: Node) -> void:
	nodo.desactivar()
	_en_uso.erase(nodo)
	_libres.append(nodo)


func _crear() -> Node:
	var nodo := _escena.instantiate()
	_contenedor.add_child(nodo)
	_al_crear.call(nodo)
	nodo.desactivar()
	return nodo


func en_uso() -> Array[Node]:
	return _en_uso
