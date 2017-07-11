extends Button

# Previous Scene Path
export (String) var prev_scene_path
onready var prev_scene = load(prev_scene_path)
# Pressed button
func _pressed():
	print("EEEEEEEEEE")
	# Swap entire scene to new scene
	get_tree().change_scene_to(load(prev_scene_path))

func _on_button_back_pressed():
	print(prev_scene)
	get_tree().change_scene_to(prev_scene)
	pass # replace with function body
