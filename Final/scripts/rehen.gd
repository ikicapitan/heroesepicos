tool

extends KinematicBody2D
#REHEN Y STIMPY
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_Area2D_body_enter( body ):
	if(body.is_in_group("player")):
		remove_from_group("not_saved")
		get_tree().get_nodes_in_group("main")[0].hostage_saved()
		get_tree().get_nodes_in_group("sfx")[0].play("hostage_saved")
		queue_free()

	
func muerte():
	remove_from_group("hostage")
	get_node("CollisionShape2D").queue_free()
	get_node("Sprite").set_frame(1)
	get_tree().get_nodes_in_group("sfx")[0].play("shout")
	get_tree().get_nodes_in_group("main")[0].hostage_killed()

func _draw():
	if get_tree()!=null && get_tree().is_editor_hint() && is_in_group("objetivo"):
		for jugadores in get_tree().get_nodes_in_group("player"):
			draw_line(Vector2(),jugadores.get_global_pos()-get_global_pos(),Color(1,0,0,1),1)