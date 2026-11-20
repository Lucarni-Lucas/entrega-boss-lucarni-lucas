shader_type canvas_item;

uniform float radio = 100.0;
uniform float perspectiva = 0.45;
uniform float irregularidad = 0.08;
uniform float grosor_borde = 4.0;
uniform float grosor_grieta = 3.0;
uniform int grietas = 7;
uniform float largo_grieta = 0.45;
uniform vec4 color_hoyo : source_color = vec4(0.227, 0.227, 0.251, 1.0);
uniform vec4 color_sombra : source_color = vec4(0.149, 0.149, 0.169, 1.0);
uniform vec4 color_labio : source_color = vec4(0.478, 0.478, 0.502, 1.0);
uniform vec4 color_borde : source_color = vec4(0.125, 0.125, 0.141, 1.0);

varying vec2 lugar;
varying flat vec2 semilla;

float azar(vec2 base, float variante) {
	return fract(sin(dot(base + variante, vec2(12.9898, 78.233))) * 43758.5453);
}

float limite(float angulo) {
	float fase = azar(semilla, 1.0) * 6.2831853;
	return 1.0 + irregularidad * (0.55 * sin(5.0 * angulo + fase) + 0.3 * sin(9.0 * angulo + fase * 1.7) + 0.15 * sin(14.0 * angulo + fase * 2.3));
}

float en_pixeles(float valor) {
	return valor / max(fwidth(valor), 0.00001);
}

void vertex() {
	lugar = VERTEX;
	semilla = floor(COLOR.rg * 97.0);
}

void fragment() {
	vec2 punto = vec2(lugar.x, lugar.y / perspectiva) / radio;
	float distancia_centro = length(punto);
	float angulo = atan(punto.y, punto.x);
	float borde = limite(angulo);
	float adentro = distancia_centro - borde;
	float adentro_px = en_pixeles(adentro);

	vec2 hacia_sombra = (punto - vec2(0.0, -0.3)) / vec2(0.8, 0.62);
	float sombra = 1.0 - smoothstep(0.95, 1.05, length(hacia_sombra));
	vec3 color = mix(color_hoyo.rgb, color_sombra.rgb, sombra);
	float labio = smoothstep(-0.2, -0.14, adentro) * (1.0 - smoothstep(-0.08, -0.04, adentro)) * smoothstep(0.1, 0.5, punto.y);
	color = mix(color, color_labio.rgb, labio);
	float relleno = 1.0 - smoothstep(-0.5, 0.5, adentro_px);

	float media_linea = grosor_borde * 0.5;
	float linea = 1.0 - smoothstep(media_linea - 0.5, media_linea + 0.5, abs(adentro_px));

	float grieta = 0.0;
	for (int i = 0; i < grietas; i++) {
		float indice = float(i);
		float base = (indice + azar(semilla, indice + 3.0) * 0.6) / float(grietas) * 6.2831853;
		float largo = largo_grieta * mix(0.6, 1.2, azar(semilla, indice + 11.0));
		float tramo = distancia_centro - limite(base);
		float avance = clamp(tramo / largo, 0.0, 1.0);
		float desvio = base + 0.14 * sin(tramo * 16.0 + azar(semilla, indice + 5.0) * 6.2831853) * avance;
		float diferencia = atan(sin(angulo - desvio), cos(angulo - desvio));
		float separacion = en_pixeles(abs(diferencia) * distancia_centro);
		float ancho = grosor_grieta * 0.5 * (1.0 - avance * 0.7);
		float dentro_del_tramo = step(-0.02, tramo) * (1.0 - smoothstep(largo * 0.85, largo, tramo));
		grieta = max(grieta, (1.0 - smoothstep(ancho - 0.5, ancho + 0.5, separacion)) * dentro_del_tramo);
	}

	color = mix(color, color_borde.rgb, max(linea, grieta * step(0.0, adentro)));
	float alfa = max(max(relleno, linea), grieta);
	COLOR = vec4(color, alfa * COLOR.a);
}
