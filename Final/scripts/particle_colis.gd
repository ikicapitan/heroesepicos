extends Node

func _ready():
	get_node("Particles2D").set_emitting(true)

func _on_Timer_timeout():
	queue_free()
