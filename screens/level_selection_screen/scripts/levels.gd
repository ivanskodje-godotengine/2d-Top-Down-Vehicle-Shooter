extends Node2D

var level_array = [] # All levels
var selected_level = null

onready var player = get_parent().get_node("player")

# Start
func _ready():
	# Count each level, assign them into an array
	var count = 0
	for child in get_children():
		level_array.append(child)
		# If this is our first child, add as selected level
		if(selected_level == null):
			selected_level = 0
			player.set_pos(get_level().get_pos())
		
		# Increment count
		count += 1
	
	# Enable input from the player
	set_process_input(true)
	
	# Debug?
	if(global.debug):
		get_level()._pressed()


# User Input
func _input(event):
	# Do the change
	if(!player.is_moving()):
		if(event.is_action_pressed("ui_left")):
			selected_level = clamp(selected_level-1, 0, get_child_count()-1)
			update_ui()
		elif(event.is_action_pressed("ui_right")):
			selected_level = clamp(selected_level+1, 0, get_child_count()-1)
			update_ui()
		elif(event.is_action_pressed("ui_select")):
			get_level()._pressed()


# Update UI
func update_ui():
	# Move the player to the next level
	if(!player.is_moving()):
		player.move_to(get_level().get_pos())
	
	# Wait until tween has completed before grabbing focus
	get_level().grab_focus()


func get_level():
	return level_array[selected_level]
