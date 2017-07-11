extends Control

# Previous Scene
export (String) var prev_scene_path
export (PackedScene) var next_scene

# Player Image
export (NodePath) var player_image_path
onready var player_image = get_node(player_image_path)

# Player Name
export (NodePath) var player_name_path
onready var player_name = get_node(player_name_path)

# Vehicle Image
export (NodePath) var vehicle_image_path
onready var vehicle_image = get_node(vehicle_image_path)

# Vehicle Name
export (NodePath) var vehicle_name_path
onready var vehicle_name = get_node(vehicle_name_path)

# Circular Container
export (NodePath) var circular_container_path
onready var circular_container = get_node(circular_container_path)

# Rotate Timer
export (NodePath) var rotate_tween_path
onready var rotate_tween = get_node(rotate_tween_path)

# Left arrow
export (NodePath) var arrow_left_path
onready var arrow_left = get_node(arrow_left_path)

# Right arrow
export (NodePath) var arrow_right_path
onready var arrow_right = get_node(arrow_right_path)

# Continue Button
export (NodePath) var button_continue_path
onready var button_continue = get_node(button_continue_path)

# Back Button
export (NodePath) var button_back_path
onready var button_back = get_node(button_back_path)

# Path to character folders
const path_to_characters = "res://characters/"

# Characters
var characters = null

# Currently selected character
var selected_character = 0

# Rotational angle
var rotational_angle = 0

# Is rotating
var is_rotating = false

# Start
func _ready():
	# Set initial focus on Continue
	button_continue.grab_focus()
	
	
	if(global.character_array.size() == 0):
		# Load characters
		load_characters()
	
	# -- Update GUI
	update_character_selection()
	
	# Load first character
	if(characters != null):
		set_selected_character(characters[0])
	
	# Enable input events
	set_process_input(true)
	
	if(global.debug):
		_on_button_continue_pressed()


func _input(event):
	# Swap to first left character
	if(event.is_action_pressed("ui_left")):
		left_character()
	# Swap to first right character
	elif(event.is_action_pressed("ui_right")):
		right_character()
	# Select character and start game
#	if(event.is_action_pressed("ui_accept")):
#		_on_button_start_pressed()
#	
#	# Return to main menu
#	elif(event.is_action_pressed("ui_cancel")):
#		_on_button_back_pressed()


# Rotate between character
func rotate_movement(rot):
	# Play SFX
	AUDIO.play_sfx("menu_slide")
	
	# Enable rotating
	is_rotating = true
	
	# Current angle
	var start_angle = circular_container.get_start_angle_deg()
	var current_rot_angle = start_angle
	
	# Update angle
	current_rot_angle += rot
	
	# Update selected character
	if(rot < 0):
		selected_character += 1
	elif(rot > 0):
		selected_character -= 1
	
	if(selected_character < 0):
		selected_character = characters.size()-1
	
	if(selected_character >= characters.size()):
		selected_character = 0

	# Rotate
	rotate_tween.connect("tween_complete", self, "_tween_complete")
	rotate_tween.interpolate_property(circular_container, "arrange/start_angle", start_angle, current_rot_angle, 0.48, Tween.TRANS_LINEAR, Tween.EASE_IN)
	rotate_tween.start()

func _tween_complete(var obj, var key):
	# No longer rotating
	is_rotating = false
	
	# Disable pressed upon completion
	arrow_right.set_disabled(false)
	arrow_left.set_disabled(false)
	
	# Update selected character
	set_selected_character(characters[selected_character])


# ...
func update_character_selection():
	# Get characters
	characters = global.character_array
	
	# Calculate angle in degrees per rotation
	rotational_angle = 360.0 / characters.size()
	
	# Fill the circular container
	for char in characters:
		# Character texture
		var tex = char.image.duplicate()
		
		# Create character item
		var character_item = load("res://screens/selection_screen/character_item/character_item.tscn").instance()
		character_item.set_texture(tex)
		
		
		circular_container.add_child(character_item)
		
		# Update sprite pos after adding to scene (otherwise it would be 0,0)
		# sprite.set_pos(char_sprite.get_size()/2.0)

# Update image to prevent size to exceed max_size
func update_image_size(image_size, max_size):
	var ratio = 0
	# If texture height is greater than the parent, set to fit parent
	if(image_size.y > max_size.y):
		# Update ratio
		ratio = max_size.y / image_size.y
		
		# Fit height to parent height
		image_size.y = max_size.y
		
		# Fit width to match aspect ratio
		image_size.x *= ratio
	
	# If texture width is greater than the parent, set to fit parent
	if(image_size.x > max_size.x):
		# Update ratio
		ratio = max_size.x / image_size.x
		
		# Fit height to parent height
		image_size.x = max_size.x
		
		# Fit width to match aspect ratio
		image_size.y *= ratio
	
	return image_size


# Set selected character 
func set_selected_character(char):
	# Store selected character in global
	global.selected_character = char
	
	# Load Textures
	player_image.set_texture(char.image)
	vehicle_image.set_texture(char.vehicle.image_body)
	
	# Load Names
	player_name.set_text(char.name)
	vehicle_name.set_text(char.vehicle.name)


# Load all characters
func load_characters():
	# Get all characters
	var dir = Directory.new()
	
	if(dir.open(path_to_characters) == OK):
		# Open stream
		dir.list_dir_begin()
		
		# Get first name
		var name = dir.get_next()
		print("---- Directory Name: " + str(name))
		
		# Iterate through all names (folders)
		while(name != ""):
			if(dir.current_is_dir() && name != "." && name != ".."):
				# Character settings
				var char_config = ConfigFile.new()
				
				# Load settings, if possible
				if(char_config.load(path_to_characters + name + "/character.cfg") == OK):
					# Get character vehicle
					var vehicle = global.Vehicle.new()
					vehicle.name = char_config.get_value("vehicle", "name")
					vehicle.image_body = load(path_to_characters + name + "/" + char_config.get_value("vehicle", "image_body"))
					vehicle.speed = char_config.get_value("vehicle", "speed")
					vehicle.acceleration = char_config.get_value("vehicle", "acceleration")
					
					# Get character
					var character = global.Character.new()
					character.name = char_config.get_value("character", "name")
					character.image = load(path_to_characters + name + "/" + char_config.get_value("character", "image"))
					character.vehicle = vehicle
					
					# Add character to array
					global.character_array.append(character)
			# Get next name; continue iteration if not empty
			name = dir.get_next()


# Previous Scene
func _on_button_back_pressed():
	change_scene(load(prev_scene_path))

# Next scene
func _on_button_continue_pressed():
	change_scene(next_scene, true)


# Change scene 
# 
# clear is used to control whether or not we want to completely change scene, 
# or just go back to a menu, keeping the original scene tree.
func change_scene(new_scene, clear = false):
	# Play sound sfx
	AUDIO.play_sfx("menu_action")
	
	if(!clear):
		# Create new menu instance
		var scene = new_scene.instance()
		
		# Add to parent
		get_parent().call_deferred("add_child", scene)
		
		# Destroy self
		self.queue_free()
	else:
		# Swap entire scene to new scene
		get_tree().change_scene_to(new_scene)


# Change character towards left
func left_character():
	if(!is_rotating):
		# Rotate left
		rotate_movement(-rotational_angle)
		
		# Disable button
		arrow_left.set_disabled(true)

# Change character towards right
func right_character():
	if(!is_rotating):
		# Rotate right
		rotate_movement(rotational_angle)
		
		# Disable button
		arrow_right.set_disabled(true)


func _on_button_focus_enter():
	# Play sound sfx
	AUDIO.play_sfx("menu_navigation")
