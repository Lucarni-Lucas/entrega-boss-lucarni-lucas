shader_type canvas_item;

uniform vec4 color_carga : source_color = vec4(0.949, 0.698, 0.2, 1.0);
uniform float carga : hint_range(0.0, 1.0) = 0.0;
uniform float brillo : hint_range(0.0, 1.0) = 0.0;
uniform float luz_dorado = 2.2;

varying vec4 modulacion;

void vertex() {
	modulacion = COLOR;
}

void fragment() {
	vec4 textura = texture(TEXTURE, UV);
	float luma = dot(textura.rgb, vec3(0.299, 0.587, 0.114));
	vec3 dorado = color_carga.rgb * luma * luz_dorado;
	textura.rgb = mix(textura.rgb, dorado, carga) * (1.0 + brillo);
	COLOR = textura * modulacion;
}
