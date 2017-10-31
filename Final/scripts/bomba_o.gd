tool

extends Sprite

export (PackedScene) var cronometro
export (float) var tiempo
# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	if get_tree()!=null && !get_tree().is_editor_hint():	
		var newcron = cronometro.instance()
		newcron.get_node("conteo/cronometro").set_wait_time(tiempo)
		get_tree().get_nodes_in_group("hud")[0].add_child(newcron)

func _on_Area2D_body_enter( body ):
	if(body.is_in_group("player")):
		get_tree().get_nodes_in_group("cronometro")[0].defuse()
		get_tree().get_nodes_in_group("sfx")[0].play("bomb_defuse")

func _draw():
	if get_tree()!=null && get_tree().is_editor_hint():
		for jugadores in get_tree().get_nodes_in_group("player"):
			draw_line(get_node("Area2D/Sprite").get_global_pos(),jugadores.get_global_pos(),Color(1,0,0,1),1)