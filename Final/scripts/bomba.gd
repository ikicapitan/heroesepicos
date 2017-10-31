extends Label

# class member variables go here, for example:
# var a = 2
# var b = "textvar"



func _ready():
	set_fixed_process(true)
	
func _fixed_process(delta):
	var minutos = int(get_node("cronometro").get_time_left() / 60)
	var segundos = int(get_node("cronometro").get_time_left()) % 60
	set_text(str(minutos) + ":" + str(segundos))
	
func defuse():
	get_node("cronometro").stop()
	get_tree().get_nodes_in_group("main")[0].bomb_defused()

func _on_cronometro_timeout():
	get_tree().get_nodes_in_group("main")[0].time_over()
	var newExplos = get_tree().get_nodes_in_group("main")[0].bomb_explos.instance()
	newExplos.get_node("Particles2D").set_pos(get_tree().get_nodes_in_group("bomba")[0].get_pos())
	get_tree().get_nodes_in_group("sfx")[0].play("bomb_explode")
	get_tree().get_nodes_in_group("bomba")[0].get_parent().queue_free()
	get_tree().get_nodes_in_group("nivel")[0].add_child(newExplos)
