extends Path2D

export (float) var velocidad_cam

func _ready():
	set_fixed_process(true)
	get_tree().get_nodes_in_group("camera")[0].clear_current()
	get_node("PathFollow2D/Camera2D").make_current()
	var curva = Curve2D.new()
	curva.add_point(get_tree().get_nodes_in_group("objetivo")[0].get_pos())
	curva.add_point(get_tree().get_nodes_in_group("player")[0].get_pos())
	set_curve(curva)
	
func _fixed_process(delta):
	if(get_node("PathFollow2D").get_unit_offset() >= 1):
		get_node("PathFollow2D/Camera2D").clear_current()
		get_tree().get_nodes_in_group("camera")[0].make_current()
		event_handler.habilitar_periferico()
		queue_free()
	else:
		get_node("PathFollow2D").set_offset(get_node("PathFollow2D").get_offset() + delta * velocidad_cam)
		
		