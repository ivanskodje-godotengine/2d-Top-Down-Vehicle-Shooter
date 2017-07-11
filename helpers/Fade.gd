extends Node

# Controller to prevent running more than one 'fade' at a time
var is_fading = false


func _ready():
	pass

func fade_to(scene_from, scene_to):
	# Create Fade scene
	var fade = load("res://fade/fade.tscn").instance()
	scene_from.add_child(fade)



func fade_out(scene):
	pass
	
func fade_in(scene):
	pass


