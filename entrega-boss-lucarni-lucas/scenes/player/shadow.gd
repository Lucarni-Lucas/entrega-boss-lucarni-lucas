extends Sprite2D


func actualizar(z: float, params: PlayerParams) -> void:
	var altura_relativa := clampf(z / params.sombra_altura_max, 0.0, 1.0)
	scale = Vector2.ONE * lerpf(1.0, params.sombra_escala_min, altura_relativa)
	modulate.a = lerpf(params.sombra_alpha_max, params.sombra_alpha_min, altura_relativa)
