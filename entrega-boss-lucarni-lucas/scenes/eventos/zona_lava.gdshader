shader_type canvas_item;

uniform float radio = 160.0;
uniform float perspectiva = 0.65;
uniform float tamano_centro = 0.65;
uniform float grosor_borde = 6.0;
uniform int burbujas = 3;
uniform float burbujas_por_segundo = 1.4;
uniform float tiempo = 0.0;
uniform vec4 color_lava = vec4(0.94, 0.48, 0.1, 1.0);
uniform vec4 color_centro = vec4(1.0, 0.71, 0.23, 1.0);
uniform vec4 color_borde = vec4(0.08, 0.08, 0.09, 1.0);
uniform vec4 color_burbuja = vec4(1.0, 0.94, 0.7, 1.0);

varying vec2 lugar;
varying flat vec2 semilla;
varying flat float escala;

float distancia_a_elipse(vec2 punto, vec2 ejes) {
	vec2 normalizado = punto / ejes;
	float largo = length(normalizado);
	return (largo - 1.0) * largo / max(length(normalizado / ejes), 0.0001);
}

float azar(vec2 base, float variante) {
	return fract(sin(dot(base + variante, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex() {
	lugar = VERTEX;
	semilla = MODEL_MATRIX[3].xy;
	escala = length(MODEL_MATRIX[0].xy);
}

void fragment() {
	vec2 ejes = vec2(radio, radio * perspectiva);
	float distancia = distancia_a_elipse(lugar, ejes);
	float suave = max(fwidth(distancia), 0.001);
	float centro = 1.0 - smoothstep(-suave, suave, distancia_a_elipse(lugar, ejes * tamano_centro));
	vec3 color = mix(color_lava.rgb, color_centro.rgb, centro);
	for (int i = 0; i < burbujas; i++) {
		float indice = float(i);
		float fase = fract(tiempo * burbujas_por_segundo + indice / float(burbujas));
		float angulo = azar(semilla, indice) * 6.2831853;
		float lejos = radio * tamano_centro * mix(0.2, 1.1, azar(semilla, indice + 7.0));
		vec2 posicion = vec2(cos(angulo), sin(angulo) * perspectiva) * lejos;
		float anillo = abs(length(lugar - posicion) - (3.0 + fase * 6.0) / escala);
		float visible = 1.0 - smoothstep(1.0 / escala - suave, 1.0 / escala + suave, anillo);
		color = mix(color, color_burbuja.rgb, visible * (1.0 - fase));
	}
	float media_linea = grosor_borde * 0.5 / escala;
	float borde = 1.0 - smoothstep(media_linea - suave, media_linea + suave, -distancia);
	color = mix(color, color_borde.rgb, borde);
	float alfa = 1.0 - smoothstep(media_linea - suave, media_linea + suave, distancia);
	COLOR = vec4(color, alfa * COLOR.a);
}
