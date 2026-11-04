shader_type canvas_item;

uniform float radio = 600.0;
uniform float borde = 150.0;
uniform float perspectiva = 0.65;
uniform float oscuridad : hint_range(0.0, 1.0) = 0.95;
uniform float fuerza : hint_range(0.0, 1.0) = 0.0;

varying vec2 local;

void vertex() {
	local = VERTEX;
}

void fragment() {
	float distancia = length(vec2(local.x, local.y / perspectiva));
	COLOR = vec4(0.0, 0.0, 0.0, smoothstep(radio, radio + borde, distancia) * oscuridad * fuerza);
}
