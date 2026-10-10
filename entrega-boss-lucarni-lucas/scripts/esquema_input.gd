extends Node

signal cambio(esquema: Esquema)

enum Esquema { TECLADO_MOUSE, TECLADO, JOYSTICK }

const _CRUZ := preload("res://assets/ui/botones/cruz.svg")
const _CIRCULO := preload("res://assets/ui/botones/circulo.svg")
const _CUADRADO := preload("res://assets/ui/botones/cuadrado.svg")
const _TRIANGULO := preload("res://assets/ui/botones/triangulo.svg")
const TECLAS := {
	"mover": ["W / A / S / D", "← / ↑ / ↓ / →", "Stick izq"],
	"saltar": ["Espacio", "V", _CRUZ],
	"ground_pound": ["Espacio", "V", _CRUZ],
	"slash": ["Clic izq", "C", _CUADRADO],
	"dive": ["Clic der", "X", _TRIANGULO],
	"boomerang": ["Shift", "Z", _CIRCULO],
	"pausa": ["Esc / P", "Esc / P", "Start"],
}
const _TECLAS_MOUSE := [KEY_W, KEY_A, KEY_S, KEY_D, KEY_SPACE, KEY_SHIFT]
const _TECLAS_TECLADO := [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_V, KEY_C, KEY_X, KEY_Z]
const _ZONA_MUERTA_STICK := 0.5

var actual := Esquema.TECLADO


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _input(event: InputEvent) -> void:
	var nuevo := _esquema_de(event)
	if nuevo != actual:
		actual = nuevo
		cambio.emit(actual)


func tecla(accion: String) -> Variant:
	return TECLAS[accion][actual]


func _esquema_de(event: InputEvent) -> Esquema:
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
