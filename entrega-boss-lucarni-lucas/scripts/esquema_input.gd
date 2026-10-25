extends Node

signal cambio(esquema: Esquema)

enum Esquema { TECLADO_MOUSE, TECLADO, JOYSTICK }

const DIRECCIONES := ["mover_arriba", "mover_izquierda", "mover_abajo", "mover_derecha"]
const TECLAS := {
	"mover": [["w", "a", "s", "d"], ["flecha_arriba", "flecha_izquierda", "flecha_abajo", "flecha_derecha"], ["stick"]],
	"mover_arriba": [["w"], ["flecha_arriba"], ["stick_arriba"]],
	"mover_izquierda": [["a"], ["flecha_izquierda"], ["stick_izquierda"]],
	"mover_abajo": [["s"], ["flecha_abajo"], ["stick_abajo"]],
	"mover_derecha": [["d"], ["flecha_derecha"], ["stick_derecha"]],
	"saltar": [["espacio"], ["v"], ["cruz"]],
	"ground_pound": [["espacio"], ["v"], ["cruz"]],
	"slash": [["mouse_izquierdo"], ["c"], ["cuadrado"]],
	"dive": [["mouse_derecho"], ["x"], ["triangulo"]],
	"boomerang": [["shift"], ["z"], ["circulo"]],
	"pausa": [["esc", "p"], ["esc", "p"], ["options"]],
}
const _ICONOS := "res://assets/ui/controles/%s.svg"
const _TECLAS_MOUSE := [KEY_W, KEY_A, KEY_S, KEY_D, KEY_SPACE, KEY_SHIFT]
const _TECLAS_TECLADO := [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_V, KEY_C, KEY_X, KEY_Z]
const _ZONA_MUERTA_STICK := 0.5

var actual := Esquema.TECLADO


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	var nuevo := esquema_de(event)
	if nuevo != actual:
		actual = nuevo
		cambio.emit(actual)


func teclas(accion: String, esquema: Esquema) -> Array[Texture2D]:
	var texturas: Array[Texture2D] = []
	for nombre: String in TECLAS[accion][esquema]:
		texturas.append(load(_ICONOS % nombre))
	return texturas


func tecla(accion: String) -> Texture2D:
	return teclas(accion, actual).back()


func esquema_de(event: InputEvent) -> Esquema:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode in _TECLAS_MOUSE:
			return Esquema.TECLADO_MOUSE
		if event.physical_keycode in _TECLAS_TECLADO:
			return Esquema.TECLADO
	elif event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		return Esquema.TECLADO_MOUSE
	elif event is InputEventJoypadButton and event.pressed:
		return Esquema.JOYSTICK
	elif event is InputEventJoypadMotion and absf(event.axis_value) > _ZONA_MUERTA_STICK:
		return Esquema.JOYSTICK
	return actual
