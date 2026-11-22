extends EfectoCarta

@export var escena_bomba: PackedScene
@export var escena_estallido: PackedScene
@export var bombas := 60
@export var estallidos := 50
@export_range(0, 400, 1, "suffix:px") var alto_explosion := 100.0
@export_range(0, 600, 5, "suffix:px") var margen := 60.0
@export var intentos := 30
@export var intentos_por_apertura := 6
@export_range(1, 3, 0.05) var apertura := 1.5
@export_range(0, 1, 0.01) var caida_hasta_voladores := 0.85
@export_flags_2d_physics var mascara_enemigos := 4

var _bombas: Array[BombaWombo] = []
var _estallidos: Array[Estallido] = []
var _spawner: Spawner
var _circulo := CircleShape2D.new()
var _consulta := PhysicsShapeQueryParameters2D.new()

@onready var _golpe: Hitbox = $Golpe


func _ready() -> void:
	_spawner = get_tree().get_first_node_in_group(Spawner.GRUPO) as Spawner
	_consulta.shape = _circulo
	_consulta.collision_mask = mascara_enemigos
	_consulta.collide_with_areas = true
	_consulta.collide_with_bodies = false
	for i in bombas:
		var bomba: BombaWombo = escena_bomba.instantiate()
		bomba.exploto.connect(_on_bomba_exploto)
		jugador.get_parent().add_child.call_deferred(bomba)
		_bombas.append(bomba)
	for i in estallidos:
		var estallido: Estallido = escena_estallido.instantiate()
		estallido.cantidad_chispas = 0
		add_child(estallido)
		_estallidos.append(estallido)
	jugador.combo_termino.connect(_on_combo_termino)
	jugador.volvio_al_inicio.connect(_cortar)


func cantidad_para(combo: int) -> int:
	var params := jugador.params
	return floori(float(mini(combo, params.wombo_combo_max)) / params.wombo_cada_combo)


func bombas_activas() -> Array[BombaWombo]:
	var activas: Array[BombaWombo] = []
	activas.assign(_bombas.filter(func(bomba: BombaWombo) -> bool: return bomba.is_inside_tree() and bomba.activa()))
	return activas


func ubicar(retrasos: PackedFloat32Array, mechas: PackedFloat32Array, apuntados: Array[Enemigo] = []) -> PackedVector2Array:
	var params := jugador.params
	var perspectiva := params.anim_perspectiva
	var minima := params.wombo_distancia_minima
	var celda := maxf(minima, 1.0)
	var objetivos := _objetivos()
	var cercanos := objetivos.duplicate()
	if params.wombo_precisas > 0:
		var centro_jugador := jugador.global_position
		cercanos.sort_custom(func(a: Enemigo, b: Enemigo) -> bool: return a.global_position.distance_squared_to(centro_jugador) < b.global_position.distance_squared_to(centro_jugador))
	var siguiente := 0
	var zona := _spawner.area.grow(-margen) if _spawner else Rect2(jugador.global_position - Vector2.ONE * 1500.0, Vector2.ONE * 3000.0)
	var grilla := {}
	var puntos := PackedVector2Array()
	for i in retrasos.size():
		var enemigo: Enemigo = null
		var punto := Vector2.INF
		if i < params.wombo_precisas:
			while siguiente < cercanos.size() and punto == Vector2.INF:
				var cercano: Enemigo = cercanos[siguiente]
				siguiente += 1
				var previsto := prever(cercano, retrasos[i], mechas[i]).clamp(zona.position, zona.end)
				if _ocupar(previsto, grilla, celda, perspectiva, minima):
					enemigo = cercano
					punto = previsto
		if punto == Vector2.INF and not objetivos.is_empty():
			var dispersion := params.wombo_dispersion
			for intento in intentos:
				if intento > 0 and intento % intentos_por_apertura == 0:
					dispersion *= apertura
				enemigo = objetivos.pick_random()
				var angulo := randf() * TAU
				var desvio := Vector2(cos(angulo), sin(angulo) * perspectiva) * dispersion * sqrt(randf())
				var candidato := (prever(enemigo, retrasos[i], mechas[i]) + desvio).clamp(zona.position, zona.end)
				if _ocupar(candidato, grilla, celda, perspectiva, minima):
					punto = candidato
					break
		elif punto == Vector2.INF:
			var candidato := jugador.global_position.clamp(zona.position, zona.end)
			if _ocupar(candidato, grilla, celda, perspectiva, minima):
				punto = candidato
		puntos.append(punto)
		apuntados.append(enemigo if punto != Vector2.INF else null)
	return puntos


func _ocupar(candidato: Vector2, grilla: Dictionary, celda: float, perspectiva: float, minima: float) -> bool:
	var lugar := Vector2i(floori(candidato.x / celda), floori(candidato.y / perspectiva / celda))
	if not _libre(candidato, lugar, grilla, perspectiva, minima):
		return false
	var lista: PackedVector2Array = grilla.get(lugar, PackedVector2Array())
	lista.append(candidato)
	grilla[lugar] = lista
	return true


func prever(enemigo: Enemigo, retraso: float, mecha: float) -> Vector2:
	var params := jugador.params
	var tiempo := retraso + params.wombo_caida + mecha
	if enemigo.params.altura_vuelo > 0.0:
		tiempo = retraso + params.wombo_caida * caida_hasta_voladores
	return prever_en(enemigo, tiempo)


func prever_en(enemigo: Enemigo, tiempo: float) -> Vector2:
	return enemigo.global_position.move_toward(enemigo.destino(), enemigo.velocidad_maxima() * maxf(tiempo, 0.0))


func _meta_de(bomba: BombaWombo) -> Vector2:
	var enemigo := bomba.objetivo
	var tiempo := bomba.tiempo_hasta_aire(caida_hasta_voladores) if enemigo.params.altura_vuelo > 0.0 else bomba.tiempo_hasta_explotar()
	return prever_en(enemigo, tiempo) + bomba.desvio


func _libre(candidato: Vector2, lugar: Vector2i, grilla: Dictionary, perspectiva: float, minima: float) -> bool:
	for x in range(-1, 2):
		for y in range(-1, 2):
			for otro: Vector2 in grilla.get(lugar + Vector2i(x, y), PackedVector2Array()):
				var d := otro - candidato
				if Vector2(d.x, d.y / perspectiva).length() < minima:
					return false
	return true


func _objetivos() -> Array[Enemigo]:
	var vivos: Array[Enemigo] = []
	var en_pantalla: Array[Enemigo] = []
	var pantalla := get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_visible_rect()
	if _spawner:
		for enemigo in _spawner.enemigos_activos():
			if enemigo.muerto:
				continue
			vivos.append(enemigo)
			if pantalla.has_point(enemigo.global_position):
				en_pantalla.append(enemigo)
	return en_pantalla if not en_pantalla.is_empty() else vivos


func _voladores() -> Array[Enemigo]:
	var voladores: Array[Enemigo] = []
	if _spawner:
		for enemigo in _spawner.enemigos_activos():
			if not enemigo.muerto and enemigo.params.altura_vuelo > 0.0:
				voladores.append(enemigo)
	return voladores


func _on_combo_termino(combo: int) -> void:
	var cantidad := cantidad_para(combo)
	if cantidad <= 0:
		return
	var params := jugador.params
	var tandas := mini(params.wombo_tandas, cantidad)
	var retrasos := PackedFloat32Array()
	var mechas := PackedFloat32Array()
	for i in cantidad:
		retrasos.append(floori(float(i) * tandas / cantidad) * params.wombo_entre_tandas)
		mechas.append(params.wombo_mecha + randf() * params.wombo_variacion_mecha)
	var apuntados: Array[Enemigo] = []
	var puntos := ubicar(retrasos, mechas, apuntados)
	var voladores := _voladores()
	for i in puntos.size():
		if puntos[i] == Vector2.INF:
			continue
		var bomba: BombaWombo = _bombas.pop_front()
		_bombas.push_back(bomba)
		bomba.lanzar(puntos[i], retrasos[i], params.wombo_caida, mechas[i], voladores, params.anim_perspectiva)
		if apuntados[i]:
			bomba.apuntar(apuntados[i], puntos[i] - prever(apuntados[i], retrasos[i], mechas[i]), _meta_de, params.wombo_radio)


func _on_bomba_exploto(bomba: BombaWombo, altura: float) -> void:
	var params := jugador.params
	var centro := bomba.global_position
	Audio.tocar_una_vez_por_cuadro(Audio.libreria.explosion_gp)
	var estallido: Estallido = _estallidos.pop_front()
	_estallidos.push_back(estallido)
	estallido.explotar(centro + Vector2(0, -altura), params.wombo_radio, params.anim_perspectiva)
	var z_min := maxf(altura - alto_explosion * 0.5, 0.0) if altura > 0.0 else 0.0
	var z_max := altura + alto_explosion * 0.5 if altura > 0.0 else alto_explosion
	_golpe.global_position = centro
	_golpe.dano = params.wombo_dano
	_golpe.empuje = params.wombo_empuje
	_circulo.radius = params.wombo_radio
	_consulta.transform = Transform2D(0.0, centro)
	for resultado in jugador.get_world_2d().direct_space_state.intersect_shape(_consulta, 64):
		var hurtbox := resultado.collider as Hurtbox
		if hurtbox == null:
			continue
		var enemigo := hurtbox.get_parent() as Enemigo
		if enemigo == null or enemigo.muerto:
			continue
		var d := enemigo.global_position - centro
		if Vector2(d.x, d.y / params.anim_perspectiva).length() > params.wombo_radio:
			continue
		if Altura.rangos_se_tocan(z_min, z_max, hurtbox.z_min, hurtbox.z_max):
			hurtbox.recibir_golpe(_golpe)


func _cortar() -> void:
	for bomba in _bombas:
		if bomba.is_inside_tree():
			bomba.apagar()
	for estallido in _estallidos:
		estallido.desactivar()
