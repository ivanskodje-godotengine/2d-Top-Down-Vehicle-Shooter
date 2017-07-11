extends Control

# Next Scene
export (PackedScene) var next_scene

# Singleplayer Button
export (NodePath) var singleplayer_button_path
onready var singleplayer_button = get_node(singleplayer_button_path)

# Quit Button
export (NodePath) var quit_button_path
onready var quit_button = get_node(quit_button_path)

# Background Music
export (AudioStream) var background_music

func _ready():
	# Debug
	if(global.debug):
		_on_button_start_game_pressed()
	
	# Set initial focus on the Start Button
	singleplayer_button.grab_focus()
	
	# Start music
	AUDIO.play_music(background_music)



# On Quit Pressed
func _on_button_quit_pressed():
	AUDIO.play_sfx("menu_action")
	get_tree().quit()


# On Start Game Pressed
func _on_button_start_game_pressed():
	# Play sound sfx
	AUDIO.play_sfx("menu_action")
	
	# Create new menu instance
	var scene = next_scene.instance()
	
	# Add to parent
	get_parent().call_deferred("add_child", scene)
	
	# Destroy self
	self.queue_free()
	


# Whenever we hover over a button or navigate using keyboard/controller,
# we play off a sound effect
func _on_button_selected():
	AUDIO.play_sfx("menu_navigation")