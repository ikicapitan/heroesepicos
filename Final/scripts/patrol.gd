tool

extends KinematicBody2D

export (float) var MOV_SPEED
export (float) var ROT_SPEED
export (float) var ROT_SPEED_R
export (float) var VISION_GRADOS
export (float) var PRECISION #0 a 100%
var nav = Navigation2D
var path = []
var goal = Vector2Array()
var target = Vector2()
var index = 0
var nivel_alerta = 0
var rotac_rayc = 0
var direcc_rayc = false #falso para izquierda, verdadero para derecha
var can_shot = true


enum estado {patrullando, persiguiendo, disparando, vigilando}
var estado_npc = estado.patrullando

func _ready():
	if get_tree()!=null && !get_tree().is_editor_hint():
		set_fixed_process(true)
		for nodos in get_parent().get_node("patrol_points").get_children():
			goal.append(nodos.get_pos())
		nav = get_tree().get_nodes_in_group("nav")[0]
		update_path()
		var todosraycast = get_tree().get_nodes_in_group("raycast")
		for raycast in todosraycast:
			get_node("RayCast2D").add_exception(raycast)
		var patrulla = get_tree().get_nodes_in_group("npc")
		for vigilante in patrulla:
			get_node("RayCast2D").add_exception(vigilante)
	
func _fixed_process(delta):
	
	if(get_node("RayCast2D").is_colliding()):
		var col = get_node("RayCast2D").get_collider()
		if(col.is_in_group("player")):
			if(!col.is_in_group("vestido") or is_in_group("officer") or nivel_alerta > 20):
				get_tree().call_group(0,"patrulla","dar_alarma",col.get_pos())
				estado_npc = estado.disparando
				target = col.get_pos()
				update_path()
				nivel_alerta = 100
				if(can_shot):
					var newshot = get_tree().get_nodes_in_group("main")[0].shot_colis.instance()
					newshot.get_node("Particles2D").set_pos(get_node("RayCast2D").get_collision_point())
					get_parent().add_child(newshot)
					if(shot()):
						get_node("RayCast2D").get_collider().muerte()
						estado_npc = estado.persiguiendo
		elif(nivel_alerta > 50 and col.is_in_group("hostage")):
			if(can_shot):
				if(shot()):
					get_node("RayCast2D").get_collider().muerte()
		elif(estado_npc == estado.disparando):
			estado_npc = estado.persiguiendo
	elif(estado_npc == estado.disparando):
		estado_npc = estado.persiguiendo
	
	if(path.size() > 1):
		var d = get_pos().distance_to(path[0])
		var angulo = get_angle_to(path[0])
		rotate(angulo * ROT_SPEED * delta)
		if get_node("RayCast2D").get_rotd() < -VISION_GRADOS:
			direcc_rayc = false
		elif get_node("RayCast2D").get_rotd() > VISION_GRADOS:
			direcc_rayc = true
		
		var modificador = 1
		
		if(direcc_rayc):
			modificador = 1
		else:
			modificador = -1
		
		if(estado_npc != estado.disparando):
			get_node("RayCast2D").rotate(modificador*-ROT_SPEED_R*delta)

		if(d > 2):
			if(estado_npc != estado.disparando):
				set_pos(get_pos().linear_interpolate(path[0], (MOV_SPEED * delta)/d))
		else:
			path.remove(0)
	else:
		if(estado_npc == estado.patrullando):
			if(index < goal.size()-1):
				index+= 1
			else:
				index = 0
		elif(estado_npc == estado.persiguiendo):
			var radio = Vector2(70,0)
			radio = radio.rotated(rand_range(0,360))
			target = radio + get_pos()
			nivel_alerta-= 10
			if(nivel_alerta < 10):
				estado_npc = estado.patrullando
		update_path()

func dar_alarma(posicion):
	if(estado_npc != estado.disparando):
		target = posicion
		estado_npc = estado.persiguiendo
		nivel_alerta = 100
		update_path()

	
func update_path():
	if(estado_npc == estado.patrullando):
			path = nav.get_simple_path(get_pos(), goal[index], false)
	elif(estado_npc == estado.persiguiendo or estado_npc == estado.disparando):
		path = nav.get_simple_path(get_pos(), target, false)

func shot():
	can_shot = false
	get_node("cooldown").start()
	get_tree().get_nodes_in_group("sfx")[0].play("shot2")
	if(rand_range(0,100) <= PRECISION):
		return true
	else:
		return false
		
func _on_cooldown_timeout():
	can_shot = true

func muerte():
	remove_from_group("npc")
	get_node("CollisionShape2D").queue_free()
	get_tree().get_nodes_in_group("main")[0].check_enemies()
	get_node("Sprite").set_frame(1)
	get_tree().get_nodes_in_group("sfx")[0].play("shout2",true)
	set_script(null)
	
func cegar(var time):
	get_node("RayCast2D").set_enabled(false)
	var tmr = Timer.new()
	tmr.set_one_shot(true)
	tmr.set_wait_time(time)
	tmr.connect("timeout", self, "fin_cegar",[tmr])
	tmr.start()
	get_parent().add_child(tmr)
	
	
func fin_cegar(var tmr):
	get_node("RayCast2D").set_enabled(true)
	tmr.queue_free()
	nivel_alerta = 100
	estado.persiguiendo
	
func _draw():
	if get_tree()!=null && get_tree().is_editor_hint():
		var primer = null
		var nodo_primero = Vector2()
		var nodo_anterior = Vector2()
		for nodos in get_parent().get_node("patrol_points").get_children():
			if(!primer):
				nodo_anterior = nodos.get_global_pos()-get_global_pos()
				nodo_primero = nodo_anterior
				primer = true
			else:
				var nodo_actual = nodos.get_global_pos()-get_global_pos()
				draw_line(nodo_anterior,nodo_actual,Color(0,0,0.5,1),1)
				#draw_circle(nodos.get_global_pos()-get_global_pos(),10,Color(0,0,1,1))
				nodo_anterior = nodos.get_global_pos()-get_global_pos()
		draw_line(nodo_anterior, nodo_primero ,Color(0,0,0.5,1),1)
		if(is_in_group("officer")):
			draw_circle(get_node("Sprite").get_global_pos() - get_global_pos(), 25, Color(0.5,0,0.5,0.5))