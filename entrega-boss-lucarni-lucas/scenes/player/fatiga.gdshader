shader_type canvas_item;

uniform float desaturacion : hint_range(0.0, 1.0) = 0.0;
uniform float brillo : hint_range(0.0, 1.0) = 0.0;

varying vec4 modulacion;

void vertex() {
	modulacion = COLOR;
}

void fragment() {
	vec4 textura = texture(TEXTURE, UV);
	float luma = dot(textura.rgb, vec3(0.299, 0.587, 0.114));
	textura.rgb = mix(textura.rgb, vec3(luma), desaturacion) * (1.0 + brillo);
	COLOR = textura * modulacion;
}
