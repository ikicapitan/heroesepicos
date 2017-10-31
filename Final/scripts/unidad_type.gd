tool

extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export var id = 0;

func _ready():
	var my_material = get_node("KinematicBody2D/Area2D/Sprite").get_material().duplicate()
	get_node("KinematicBody2D/Area2D/Sprite").set_material(my_material)
	handle_color()
	
func handle_color():
	var material = get_node("KinematicBody2D/Area2D/Sprite").get_material()
	var color_a_enviar = Color()
	
	if(id == 0):
		color_a_enviar = Color(1,1,1,1) #Verde normal
	elif(id == 1):
		color_a_enviar = Color(1,0,0,1) #Rojo
	elif(id == 2):
		color_a_enviar = Color(0,0,1,1) #Azul
	elif(id == 3):
		color_a_enviar = Color(1,0,1,1) #Violeta
	
	material.set_shader_param("color_deseado", color_a_enviar)
	get_node("KinematicBody2D/Area2D/Sprite").update() 