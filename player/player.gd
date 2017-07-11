extends KinematicBody2D

# Deadzone Adjustments
var deadzone_min = 0.05
var deadzone_max = 0.95
var left_stick_deadzone_min = 0.32
var left_stick_deadzone_max = 0.99

var speed = 20
var rotation_speed = deg2rad(2)

var current_speed = 1
var top_speed = 1

# Player Movement
var horizontal = 0 # Left and Right Turning
var vertical = 0 # Forward and Reverse

# Calculating variables
var acceleration = 0
var breaking = 0
var velocity = Vector2(0, 0)

# Weapon Spawn Positions
export (PackedScene) var front_guns_scene
onready var front_guns_pos = get_node("front_guns_pos")
onready var roof_turret_pos = get_node("roof_turret_pos")
onready var missile_launcher_pos = get_node("missile_launcher_pos")
onready var mine_dispenser_pos = get_node("mine_dispenser_pos")

# Vehicle Body Sprite
onready var vehicle_body = get_node("vehicle_body")

# Firing
var fire_1 = false # Default Front Guns
var fire_2 = false # Alt Weapon 

# Item pickup Delay (before being allowed to pickup another item
const PICKUP_DELAY = 2 # seconds
var pickup_delay = PICKUP_DELAY # Whenever pickup_delay is => PICKUP_DELAY, you can pickup

# Change weapon delay
const WEAPON_CHANGE_DELAY = 1 # sec
var weapon_change_delay = WEAPON_CHANGE_DELAY

# Me
var character = null

# Signals
# Wweapons changed
signal weapon_changed

# Weapon selected
signal weapon_selected

# Weapon SHOT!
signal weapon_shot

# Start
func _ready():
	# Get selected character from the global.
	character = global.selected_character
	
	# Update the vehicle body (sprite)
	vehicle_body.set_texture(character.vehicle.image_body)
	
	# Enable User input and Processing
	set_process_input(true)
	set_fixed_process(true)
	
	# Get top speed
	top_speed = (get_forward() * speed).length_squared()
	
	# Load Front Guns
	load_front_guns()


# Time and Movement vars
var time_pressed = 0.0
var slowdown = 3.0 # Reduces the speed 3 times as slow, as it can accelerate
var time_to_top_speed = 0.5 # 5 seconds
var going_forward = true


# Fixed Process
func _fixed_process(delta):
	# Pickup Delay
	if(pickup_delay <= PICKUP_DELAY):
		pickup_delay += delta
	
	# Pickup Delay
	if(weapon_change_delay <= WEAPON_CHANGE_DELAY):
		weapon_change_delay += delta
	
	# Gas Pedal
	if(Input.is_action_pressed("accelerate")):
		# Increase time
		time_pressed += delta
	# Break / Reverse
	elif(Input.is_action_pressed("break")):
		# Decrease time
		time_pressed -= delta
	else:
		# Is reverse
		if(time_pressed < 0):
			time_pressed += delta / slowdown
			time_pressed = clamp(time_pressed, -time_to_top_speed, 0)
		# Is going forward
		elif(time_pressed > 0):
			time_pressed -= delta / slowdown
			time_pressed = clamp(time_pressed, 0, time_to_top_speed)
	
	# Time Pressed (-top_speed, top_speed)
	time_pressed = clamp(time_pressed, -time_to_top_speed, time_to_top_speed)
	
	# Accumulated speed over time
	var time_accumulated_speed = time_pressed / time_to_top_speed
	velocity = get_forward() * speed * time_accumulated_speed
	
	# Horizontal movement
	
	# Left | Right
	horizontal = 0
	
	# Turn
	if(Input.is_action_pressed("steer_left")):
		horizontal += DIRECTION.LEFT
	elif(Input.is_action_pressed("steer_right")):
		horizontal += DIRECTION.RIGHT
	
	# Do the move. Move. Move it.
	move(velocity) 
	
	# Handles Turning Wheels
	if(Input.is_action_pressed("steer_left") || Input.is_action_pressed("steer_right")):
		# var rotational_value = current_speed / top_speed # Prevents rotation when you are driving slow
		rotate(-horizontal * rotation_speed * time_accumulated_speed)
	
	# Shooting Default Weapon?
	if(fire_1):
		front_guns_pos.get_node("front_guns").shoot()
	
	# Shooting Alternative Gun?
	if(fire_2 && current_weapon != null && weapon_change_delay >= WEAPON_CHANGE_DELAY):
		if(weakref(current_weapon).get_ref()):
			if(current_weapon.shoot()):
				emit_signal("weapon_shot")


# Returns forward direction
func get_forward():
	return Vector2(cos(get_rot() + PI/2.0), sin(get_rot() - PI/2.0))


# Returns rotation
func get_rotation():
	return get_rot()

# Used for when we move using keyboard
enum DIRECTION {
NONE = 0,
LEFT = -1,
RIGHT = 1
}

var turn_direction = DIRECTION.NONE

# Always check for user input
func _input(event):
	# Pause
	if(event.is_action_pressed("pause")):
		get_tree().set_pause(!get_tree().is_paused())
	
	# Check for Joystick Motion
	if(event.type == InputEvent.JOYSTICK_MOTION):
		# Acceleration
		if(event.is_action("accelerate")):
			# If our value has exceeded max deadzone, put on max speed
			if(event.value > deadzone_max):
				acceleration = 1
			elif(event.value > deadzone_min):
				acceleration = event.value
			else:
				acceleration = 0
			vertical =  acceleration - breaking
		
		# Breaking
		if(event.is_action("break")):
			if(event.value > deadzone_max):
				breaking = 1
			elif(event.value > deadzone_min):
				breaking = event.value
			else:
				breaking = 0
			vertical = acceleration - breaking
		
		# Left | Right
		if(event.is_action("steer_left") || event.is_action("steer_right")):
			if(event.value > left_stick_deadzone_max):
				horizontal = 1
			elif(event.value < -left_stick_deadzone_max):
				horizontal = -1
			elif(abs(event.value) > left_stick_deadzone_min):
				horizontal = event.value
			else:
				horizontal = 0
	
	# WEAPON SELECTION INPUT
	if(event.is_action_pressed("prev_weapon")):
		prev_weapon()
	elif(event.is_action_pressed("next_weapon")):
		next_weapon()
	
	# ------- WEAPONS -------
	# Default Front Guns
	if(event.is_action_pressed("fire1")):
		fire_1 = true
	elif(event.is_action_released("fire1")):
		fire_1 = false
	
	# Alternative Guns
	if(event.is_action_pressed("fire2")):
		fire_2 = true
	elif(event.is_action_released("fire2")):
		fire_2 = false

# Load the front guns!
func load_front_guns():
	var front_guns_instance = front_guns_scene.instance()
	front_guns_pos.add_child(front_guns_instance)

# Weapon Vars
const MAX_WEAPON_COUNT = 2 
var weapons = []
var current_index = 0

# Current selected weapon
var current_weapon = null

# This is run when you hit a weapon pickup
func load_weapon(weapon_id, ammo = 0):
	# Prevents accidentically picking up the weapon we dropped
	if(pickup_delay >= PICKUP_DELAY): 
		# Delay to 0
		pickup_delay = 0
				
		# Prev current weapon index
		var prev_index = 0
		
		# Used to control whether or not we want to set the added weapon as current
		var replacing = false
		
		# Check if we already have the weapon
		for weapon in weapons:
			if(weapon.id == weapon_id):
				if(ammo != 0):
					weapon.ammo_count = clamp(weapon.ammo_count + ammo, 1, weapon.max_ammo)
				else:
					weapon.ammo_count = weapon.max_ammo
				emit_signal("weapon_shot")
				return true # returns true in order to get the weapon to disappear
		
		# If we have reached max weapons
		if(weapons.size() == MAX_WEAPON_COUNT):
			# Drop selected weapon on the ground
			# Get the index of current weapon
			prev_index = weapons.find(current_weapon)
			
			# weapons.erase(current_weapon) # Remove from array
			
			# Drop a weapon pickup
			current_weapon.drop_weapon()
			
			# Remove weapon from everything 
			current_weapon.deconstruct()
			
			# Enable replacement
			replacing = true
		
		# Add the new weapon
		var weapon_instance = null
		if(weapon_id == Weapon.ROOF_TURRET):
			# Do we already have it?
			weapon_instance = load("res://entities/weapons/roof_turret/roof_turret.tscn").instance()
			weapon_instance.id = weapon_id # Used by dropping / weapon system
			roof_turret_pos.add_child(weapon_instance)
			weapon_instance.init(targets)
		elif(weapon_id == Weapon.MISSILE_LAUNCHER):
			weapon_instance = load("res://entities/weapons/missile_launcher/missile_launcher.tscn").instance()
			weapon_instance.id = weapon_id
			missile_launcher_pos.add_child(weapon_instance)
		elif(weapon_id == Weapon.MINE_DISPENSER):
			weapon_instance = load("res://entities/weapons/mine_dispenser/mine_dispenser.tscn").instance()
			weapon_instance.id = weapon_id
			weapon_instance.player = self # TEMP Solution
			mine_dispenser_pos.add_child(weapon_instance)
		else:
			# What? This should never happen... !
			return false
		
		if(ammo != 0):
			weapon_instance.ammo_count = ammo
		
		# Add to array
		if(replacing):
			weapons[prev_index] = weapon_instance
		else:
			weapons.append(weapon_instance)
		
		# Notify change
		emit_signal("weapon_changed", weapons)
		
		# Set last pickup as current?
		if(replacing || weapons.size() == 1):
			emit_signal("weapon_changed", weapons)
			current_weapon = weapon_instance
			emit_signal("weapon_selected", current_weapon)
		
		# Return true to notify about our success
		return true
	else:
		# Too early to pickup
		return false

# When a weapon has been dropped, we add a delay to prevent
# accidental fire
func weapon_dropped(weapon):
	# Remove the weapon from array
	weapons.erase(weapon)
	
	# Change to a different weapon
	if(weapons.size() == 0):
		current_weapon = null
	else:
		# Start the delay by setting it to 0
		weapon_change_delay = 0
		
		# Change to a prev weapon
		prev_weapon()
	
	emit_signal("weapon_changed", weapons)

# Swap to next weapon (right)
func next_weapon():
	if(weapons.size() == 0):
		return
	
	if(current_index + 1 < weapons.size()):
		current_index += 1
	else:
		current_index = 0
	
	# Set current weapon
	current_weapon = weapons[current_index]
	
	# Emit a strong signal
	emit_signal("weapon_selected", current_weapon)


# Swap to previous weapon (left)
func prev_weapon():
	if(weapons.size() == 0):
		return
	
	if(current_index - 1 >= 0):
		current_index -= 1
	else:
		current_index = weapons.size() - 1
	
	# Set current weapon
	current_weapon = weapons[current_index]
	
	# Emit a strong signal
	emit_signal("weapon_selected", current_weapon)


# Nearby enemies (used to inform certain weapons when they are initialized)
var targets = []

# Enter Medium Range
func _on_range_medium_body_enter( body ):
	var groups = body.get_groups()
	
	if(groups.has("enemy")):
		targets.append(body)
		
		# Do we have a roof turret?
		if(roof_turret_pos.get_child_count() > 0):
			roof_turret_pos.get_child(0).add_enemy(body)

# Exit Medium Range
func _on_range_medium_body_exit( body ):
	var groups = body.get_groups()
	
	if(groups.has("enemy")):
		targets.erase(body)
		
		# Do we have a roof turret?
		if(roof_turret_pos.get_child_count() > 0):
			roof_turret_pos.get_child(0).remove_enemy(body)