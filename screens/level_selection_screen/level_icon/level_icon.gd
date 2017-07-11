extends TextureButton

# The Level we will load
export (PackedScene) var level


# Change to level on pressed
func _pressed():
	change_scene(level)


# Change scene 
func change_scene(new_scene):
	# Play sound sfx
	AUDIO.play_sfx("menu_action")
	
	# Swap entire scene to new scene
	get_tree().change_scene_to(new_scene)
