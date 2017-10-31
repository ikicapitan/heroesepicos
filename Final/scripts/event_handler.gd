extends Node

var target
var puntero
enum state {seleccionar, free_cam, mover, weapon1, weapon2 }
var estado = state.seleccionar
var select_mark = preload("res://actors/mark_selected.tscn")
var primer_drag = Vector2()
var drag_ant =false


func habilitar_periferico():
	target = null
	set_process_input(true)
	puntero = get_tree().get_nodes_in_group("goal")[0]
	
func _input(event):
	
	if(event.is_action_pressed("seleccionar")):
		get_tree().get_nodes_in_group("sfx")[0].play("button_pressed")
		estado = state.seleccionar
		get_tree().set_input_as_handled()
		if(target != null):
			target.get_node("rango_w1").set_enabled(false)
			target.get_node("rango_w2").set_enabled(false)
	elif(event.is_action_pressed("cam_move")):
		get_tree().get_nodes_in_group("sfx")[0].play("button_pressed")
		if(target):
			var cam = get_tree().get_nodes_in_group("camera")[0]
			cam.get_parent().remove_child(cam)
			get_tree().get_nodes_in_group("main")[0].add_child(cam)
			cam.set_pos(target.get_pos())
			#target = null
		estado = state.free_cam
		
		get_tree().set_input_as_handled()
	elif(event.is_action_pressed("mover")):
		get_tree().get_nodes_in_group("sfx")[0].play("button_pressed")
		estado = state.mover
		get_tree().set_input_as_handled()
		if(target != null):
			target.get_node("rango_w1").set_enabled(false)
			target.get_node("rango_w2").set_enabled(false)
	elif(event.is_action_pressed("w1")):
		get_tree().get_nodes_in_group("sfx")[0].play("button_pressed")
		estado = state.weapon1
		get_tree().set_input_as_handled()
		if(target != null):
			target.can_shot = false
			target.get_node("cooldown").set_wait_time(target.COOLDOWN_W1)
			target.get_node("cooldown").start()
			target.get_node("rango_w1").set_enabled(true)
			target.get_node("rango_w2").set_enabled(false)
			if(target.get_parent().id == 3):
				if(target.is_in_group("vestido")):
					target.remove_from_group("vestido")
					target.get_node("Area2D/Sprite").set_texture(target.spr_original)
				else:
					target.add_to_group("vestido")
					target.get_node("Area2D/Sprite").set_texture(target.spr_espia)
	elif(event.is_action_pressed("w2")):
		get_tree().get_nodes_in_group("sfx")[0].play("button_pressed")
		estado = state.weapon2
		get_tree().set_input_as_handled()
		if(target != null):
			target.get_node("cooldown").set_wait_time(target.COOLDOWN_W2)
			target.get_node("cooldown").start()
			target.get_node("rango_w2").set_enabled(true)
			target.get_node("rango_w1").set_enabled(false)
			target.get_node("rango_w2").set_enabled(true)
	elif(event.is_action_pressed("exit_game")):
		get_tree().quit()
	
	if(event.type == InputEvent.SCREEN_TOUCH and target != null):
		if(event.pressed):
			if(estado == state.mover):
				get_tree().set_input_as_handled()
				puntero.set_pos(puntero.get_global_mouse_pos())
				target.update_path()
			elif(estado == state.weapon1):
				target.disparar_w1()
			elif(estado == state.weapon2):
				target.disparar_w2()
	elif(event.type == InputEvent.SCREEN_DRAG and estado == state.free_cam):
		if(drag_ant):
			primer_drag = event.relative_pos*3 - primer_drag
			get_tree().get_nodes_in_group("camera")[0].set_pos(get_tree().get_nodes_in_group("camera")[0].get_pos() + primer_drag)
			drag_ant = false
		else:
			drag_ant = true
			primer_drag = event.relative_pos
		get_tree().set_input_as_handled()
		