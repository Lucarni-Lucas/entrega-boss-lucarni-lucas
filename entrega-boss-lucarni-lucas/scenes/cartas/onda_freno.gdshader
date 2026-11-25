shader_type canvas_item;

uniform float radio = 0.0;
uniform float perspectiva = 0.65;
uniform float alfa = 1.0;
uniform float giro = 0.0;
uniform vec4 color : source_color = vec4(0.561, 0.690, 0.918, 1.0);
uniform vec4 color_borde : source_color = vec4(0.125, 0.125, 0.141, 1.0);
uniform float ancho = 4.0;
uniform float ancho_borde = 7.0;
uniform float largo_estela = 260.0;
uniform float alfa_estela = 0.45;
uniform int ecos = 2;
uniform float separacion_ecos = 70.0;
uniform float ancho_ecos = 4.8;
uniform int marcas = 60;
uniform float largo_marca = 22.0;
uniform float ancho_marca = 4.8;
uniform float ancho_borde_marca = 8.4;

varying vec2 punto;

void vertex() {
	punto = VERTEX;
}

float cubre(float distancia, float grosor) {
	return 1.0 - smoothstep(grosor * 0.5 - 0.5, grosor * 0.5 + 0.5, distancia);
}

vec4 encima(vec4 abajo, vec3 tono, float cobertura) {
	return vec4(tono * cobertura + abajo.rgb * (1.0 - cobertura), cobertura + abajo.a * (1.0 - cobertura));
}

float a_segmento(vec2 p, vec2 a, vec2 b) {
	vec2 ab = b - a;
	float t = clamp(dot(p - a, ab) / dot(ab, ab), 0.0, 1.0);
	return length(p - a - ab * t);
}

void fragment() {
	vec2 q = vec2(punto.x, punto.y / perspectiva);
	float f = length(q);
	float margen = largo_marca + ancho_borde_marca + 2.0;
	if (f > radio + margen || f < radio - largo_estela - margen) {
		discard;
	}
	vec2 gradiente = vec2(q.x, q.y / perspectiva) / max(f, 0.0001);
	float escala = max(length(gradiente), 0.0001);
	vec4 suma = vec4(0.0);
	float interior = max(radio - largo_estela, 0.0);
	if (largo_estela > 0.0 && f <= radio && radio > interior) {
		suma = encima(suma, color.rgb, alfa_estela * alfa * clamp((f - interior) / (radio - interior), 0.0, 1.0));
	}
	for (int k = 1; k <= ecos; k++) {
		float r = radio - separacion_ecos * float(k);
		if (r > 0.0) {
			float d = abs(f - r) / escala;
			suma = encima(suma, color.rgb, cubre(d, ancho_ecos) * alfa * (1.0 - float(k) / float(ecos + 1)));
		}
	}
	float d_anillo = abs(f - radio) / escala;
	suma = encima(suma, color_borde.rgb, cubre(d_anillo, ancho_borde) * alfa);
	suma = encima(suma, color.rgb, cubre(d_anillo, ancho) * alfa);
	if (marcas > 0) {
		float paso = 6.28318530718 / float(marcas);
		float angulo = atan(q.y, q.x);
		float cerca = round((angulo - giro) / paso);
		for (int j = -1; j <= 1; j++) {
			float i = cerca + float(j);
			float a = giro + i * paso;
			int indice = int(mod(i, float(marcas)));
			float largo = largo_marca * (indice % 5 == 0 ? 1.6 : 1.0);
			vec2 direccion = vec2(cos(a), sin(a) * perspectiva);
			float d = a_segmento(punto, direccion * (radio - largo * 0.5), direccion * (radio + largo * 0.5));
			suma = encima(suma, color_borde.rgb, cubre(d, ancho_borde_marca) * alfa);
			suma = encima(suma, color.rgb, cubre(d, ancho_marca) * alfa);
		}
	}
	if (suma.a <= 0.001) {
		discard;
	}
	COLOR = vec4(suma.rgb / suma.a, suma.a);
}
