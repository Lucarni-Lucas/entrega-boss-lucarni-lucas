shader_type canvas_item;

varying flat float destello;

void vertex() {
	float paso = floor(COLOR.r / 2.0);
	COLOR.r -= paso * 2.0;
	destello = paso / 8.0;
}

void fragment() {
	COLOR.rgb = mix(COLOR.rgb, vec3(1.0), destello);
}
