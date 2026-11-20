shader_type canvas_item;

uniform vec4 color_linea : source_color = vec4(0.91, 0.95, 1.0, 1.0);
uniform vec4 color_oscuro : source_color = vec4(0.11, 0.25, 0.54, 1.0);
uniform vec4 color_claro : source_color = vec4(0.31, 0.53, 0.91, 1.0);
uniform float opacidad = 0.85;

void fragment() {
	vec4 textura = texture(TEXTURE, UV);
	float brillo = dot(textura.rgb, vec3(0.299, 0.587, 0.114));
	vec3 relleno = mix(color_oscuro.rgb, color_claro.rgb, smoothstep(0.25, 0.75, brillo));
	float linea = 1.0 - smoothstep(0.12, 0.22, brillo);
	COLOR = vec4(mix(relleno, color_linea.rgb, linea), textura.a * opacidad * COLOR.a);
}
