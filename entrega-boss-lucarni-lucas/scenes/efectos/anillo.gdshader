shader_type canvas_item;

uniform float perspectiva = 0.65;
uniform float ancho_borde = 8.0;
uniform float ancho_interior = 4.0;
uniform vec4 color_borde = vec4(0.125, 0.125, 0.14, 1.0);
uniform vec4 color_interior = vec4(0.96, 0.95, 0.89, 1.0);

varying vec2 lugar;
varying flat float radio;

void vertex() {
	radio = length(MODEL_MATRIX[0].xy);
	lugar = VERTEX * radio;
}

void fragment() {
	vec2 ejes = vec2(radio, radio * perspectiva);
	vec2 normalizado = lugar / ejes;
	float largo = length(normalizado);
	float distancia = abs((largo - 1.0) * largo / max(length(normalizado / ejes), 0.0001));
	float suave = max(fwidth(distancia), 0.001);
	float borde = 1.0 - smoothstep(ancho_borde * 0.5 - suave, ancho_borde * 0.5 + suave, distancia);
	float interior = 1.0 - smoothstep(ancho_interior * 0.5 - suave, ancho_interior * 0.5 + suave, distancia);
	COLOR = vec4(mix(color_borde.rgb, color_interior.rgb, interior), borde * COLOR.a);
}
