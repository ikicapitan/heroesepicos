extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var duration = 0

func _ready():
	get_node("Timer").start()

func _on_Area2D_body_enter( body ):
	if(body.is_in_group("npc")):
		get_parent().get_node("KinematicBody2D").look_at(body.get_pos())
		if(get_parent().get_node("KinematicBody2D/rango_w1").is_colliding()):
			var col = get_parent().get_node("KinematicBody2D/rango_w1").get_collider()
			if(col.is_in_group("npc")):
				col.cegar(duration)
				col.path.resize(0)
				col.dar_alarma(col.get_pos())

func _on_Timer_timeout():
	queue_free()
	

