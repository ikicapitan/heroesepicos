extends KinematicBody2D

export (float) var MOV_SPEED
export (float) var ROT_SPEED
export (float) var COOLDOWN_W1
export (float) var COOLDOWN_W2
export (int) var PRECISION #porcentaje de precision
export (PackedScene) var granada_flash
export (float) var FLASH_DURATION
export (ImageTexture) var spr_original
export (ImageTexture) var spr_espia
var nav = Navigation2D
var path = []
var goal = Vector2()
var can_shot = true


func _ready():
	set_process_input(true)
	set_fixed_process(true)
	nav = get_tree().get_nodes_in_group("nav")[0]
	
func _fixed_process(delta):
	#print(path.size())

	if(path.size() > 1):
		var angulo = get_angle_to(path[0])
		rotate(angulo * ROT_SPEED * delta)
		var d = get_pos().distance_to(path[0])
		if(d > 2):
			set_pos(get_pos().linear_interpolate(path[0], (MOV_SPEED * delta)/d))
		else:
			path.remove(0)
			
			#look_at(path[0])
			

func _on_Area2D_input_event( viewport, event, shape_idx ):
	if(event_handler.estado == event_handler.state.seleccionar):
		if(event.type == InputEvent.SCREEN_TOUCH):
			if(event.pressed):
				if(event_handler.target != null):
					get_tree().get_nodes_in_group("selected")[0].queue_free()
				event_handler.target = self
				var s_mark = event_handler.select_mark.instance()
				add_child(s_mark)
				move_child(s_mark, 0)
				var cam = get_tree().get_nodes_in_group("camera")[0]
				cam.get_parent().remove_child(cam)
				get_node("Area2D").add_child(cam)
				cam.set_pos(get_pos())
				cam.set_pos(Vector2(get_pos() - cam.get_pos()))
				get_tree().set_input_as_handled()

	
func update_path():
	goal = get_tree().get_nodes_in_group("goal")[0].get_pos()
	path = nav.get_simple_path(get_pos(), goal, false)
	
func muerte():
	remove_from_group("player")
	if(event_handler.target == self):
		event_handler.target = null
		get_tree().get_nodes_in_group("selected")[0].queue_free()
	get_node("Area2D/CollisionShape2D").queue_free()
	get_tree().get_nodes_in_group("main")[0].check_players()
	get_node("Area2D/Sprite").set_frame(1)
	get_tree().get_nodes_in_group("sfx")[0].play("shout2")
	set_script(null)

func disparar_w1():
	if(can_shot and get_node("cooldown").get_time_left() == 0):
		if(get_parent().id != 1 or get_parent().id != 3):
			get_tree().get_nodes_in_group("sfx")[0].play("shot1")
		can_shot = false
		look_at(get_global_mouse_pos())
		get_node("rango_w1").force_raycast_update()
		if(rand_range(0,100) <= PRECISION):
			if(get_parent().id == 0 or get_parent().id == 2): #Asalto o Sniper
				if(get_node("rango_w1").is_colliding()):
					var newshot = get_tree().get_nodes_in_group("main")[0].shot_colis.instance()
					newshot.get_node("Particles2D").set_pos(get_node("rango_w1").get_collision_point())
					get_parent().add_child(newshot)
					var col = get_node("rango_w1").get_collider()
					if(col.is_in_group("npc")):
						col.muerte()
					elif(col.is_in_group("hostage")):
						col.muerte()
			elif(get_parent().id == 1): #Granadero
				var newGranada = granada_flash.instance()
				newGranada.duration = FLASH_DURATION
				get_parent().add_child(newGranada)
				look_at(get_global_mouse_pos())
				if(get_node("rango_w1").is_colliding()):
					newGranada.get_node("Area2D").set_pos(get_node("rango_w1").get_collision_point())
				else:
					newGranada.get_node("Area2D").set_pos(get_global_mouse_pos())
		get_node("cooldown").set_wait_time(COOLDOWN_W1)
		get_node("cooldown").start()
	

func disparar_w2():
	if(can_shot and get_node("cooldown").get_time_left() == 0):
		get_tree().get_nodes_in_group("sfx")[0].play("shot2")
		can_shot = false
		look_at(get_global_mouse_pos())
		get_node("rango_w2").force_raycast_update()
		if(get_parent().id == 3 and is_in_group("vestido")):
			remove_from_group("vestido")
			get_node("Area2D/Sprite").set_texture(spr_original)
		if(rand_range(0,100) <= PRECISION):
			if(get_node("rango_w2").is_colliding()):
				var col = get_node("rango_w2").get_collider()
				var newshot = get_tree().get_nodes_in_group("main")[0].shot_colis.instance()
				newshot.get_node("Particles2D").set_pos(get_node("rango_w2").get_collision_point())
				get_parent().add_child(newshot)
				if(col.is_in_group("npc")):
					col.muerte()
		get_node("cooldown").set_wait_time(COOLDOWN_W2)
		get_node("cooldown").start()

	

func _on_cooldown_timeout():
	can_shot = true
	get_tree().get_nodes_in_group("sfx")[0].play("reload")