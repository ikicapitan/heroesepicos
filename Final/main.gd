extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export (PackedScene) var main_elements
export (PackedScene) var shot_colis
export (PackedScene) var bomb_explos
export (PackedScene) var cam_objetive
export (PackedScene) var scn_gameover
export (int) var nivel

func _ready():
	load_level()
	
func load_level():
	
	var lvl = load("res://niveles/nivel" +str(nivel)+ ".tscn")
	if(lvl == null):
		game_over()
		return
	
	var nivel_viejo = get_tree().get_nodes_in_group("main_elements")
	
	if(nivel_viejo.size() > 0):
		get_tree().get_nodes_in_group("main_elements")[0].free()
	
	var _main = main_elements.instance()
	add_child(_main)
	
	
	
	var newnivel = lvl.instance()
	get_tree().get_nodes_in_group("main_elements")[0].add_child(newnivel)
	
	var cam = get_tree().get_nodes_in_group("camera")[0]
	cam.set_pos(get_tree().get_nodes_in_group("player")[0].get_pos())
	
	var path_obj = cam_objetive.instance()
	add_child(path_obj)
	var minimo = get_tree().get_nodes_in_group("min")[0].get_pos()
	var maximo = get_tree().get_nodes_in_group("max")[0].get_pos()
	cam.set_limit(MARGIN_LEFT, minimo.x)
	cam.set_limit(MARGIN_TOP, minimo.y)
	cam.set_limit(MARGIN_RIGHT, maximo.x)
	cam.set_limit(MARGIN_BOTTOM, maximo.y)
	
	fade_in()
	
	get_node("_main/AnimationPlayer").connect("finished",self,"fadeout_finished")
	
	
func check_players():
	var jugadores = get_tree().get_nodes_in_group("player")
	if(jugadores.size() == 0):
		fade_out()

func check_enemies():
	var enemies = get_tree().get_nodes_in_group("enemy")
	if(enemies.size() == 0):
		fade_out()
		nivel+=1

func time_over():
	fade_out()
	
func bomb_defused():
	fade_out()
	nivel+=1
	
func hostage_saved():
	var cautivos = get_tree().get_nodes_in_group("not_saved")
	if(cautivos.size() == 0):
		fade_out()
		nivel+=1
		
func hostage_killed():
	fade_out()
	
func fade_in():
	get_tree().get_nodes_in_group("main_elements")[0].get_node("AnimationPlayer").play("fadein")
	
func fade_out():
	get_tree().get_nodes_in_group("main_elements")[0].get_node("AnimationPlayer").play("fadeout")

func fadeout_finished():
	if(get_node("_main/AnimationPlayer").get_current_animation().basename() == "fadeout"):
		load_level()

func game_over():
	get_tree().change_scene_to(scn_gameover)