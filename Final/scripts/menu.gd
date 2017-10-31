extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (PackedScene) var scn_game

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass
	

func _on_bckground_pressed():
	get_tree().change_scene_to(scn_game)
