extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (Color) var color

func _ready():
	get_tree().get_nodes_in_group("sfx")[0].play("granade")
	
func _draw():
	var radio = get_shape(0).get_radius()
	var pos = Vector2(0,0)
	draw_circle(pos, radio, color)