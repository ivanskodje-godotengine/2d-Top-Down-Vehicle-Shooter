extends "res://entities/weapons/generic_weapon.gd"

# Bullet Spawn Position
onready var bullet_spawn1 = get_node("bullet_spawn1")

# Weapon active?
var is_enabled = true # turns to false when changing to another weapon

# Targets
var targets = []
var current_target = null

# Must be run when weapon is initialized - in order to be aware of nearby enemies
func init(existing_targets):
	print("--------------------------")
	if(existing_targets.size() > 0):
		# Get the targets
		targets = existing_targets
		current_target = targets[0]
		
		# Enable processing
		set_process(true)
		
		# Enable input if we have more than 1 target
		if(targets.size() > 1):
			set_process_input(true)
	pass


# Processing
func _process(delta):
	if(current_target != null):
		# Face turret towards the target
		look_at(current_target.get_pos())
		set_rotd(get_rotd() + 180)


# User Input
func _input(event):
	# If we have more than 1 target/enemy
	if(event.is_action_pressed("target_change_left")):
		var current_index = targets.find(current_target)
		if(0 != current_index):
			current_index -= 1
		else:
			current_index = targets.size()-1
		current_target = targets[current_index]
	
	elif(event.is_action_pressed("target_change_right")):
		var current_index = targets.find(current_target)
		if(targets.size() - 1 != current_index):
			current_index += 1
		else:
			current_index = 0
		current_target = targets[current_index]


# Add Enemy to our targets
func add_enemy(body):
	# If this is our first enemy, add as curent target
	if(targets.size() <= 1):
		current_target = body
	
	# Enable Process
	set_process(true)
	
	# If we have more than 1 target, enable input
	if(targets.size() > 1):
		set_process_input(true)


# Remove Enemy from our targets
func remove_enemy(body):
	# Is enemy current target?
	if(current_target == body):
		current_target = null
		
		# If we have another enemy, set first enemy as target
		if(targets.size() > 0):
			current_target = targets[0] # Note: Might not be what we want
		else:
			set_rotd(0)
			set_process(false)
	
	# If we have more than 1 target, enable input
	if(targets.size() <= 1):
		set_process_input(false)


# Update the bullet position
func update_bullet_pos(bullet):
	# Set bullet spawn
	bullet.set_global_pos(bullet_spawn1.get_global_pos())