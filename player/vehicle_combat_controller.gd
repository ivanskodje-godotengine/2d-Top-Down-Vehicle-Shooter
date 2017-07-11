extends Node

# Our equipped weapons
var equipped_weapons = []

# Current weapon
var current_weapon = null

# Maximum Number of weapons allotted
const MAX_WEAPON_COUNT = 1

# Used to create a delay after losing a weapon
const WEAPON_CHANGE_DELAY = 1.0
var weapon_change_delay = WEAPON_CHANGE_DELAY

# Positions
onready var front_guns_pos = get_parent().get_node("front_guns_pos")
onready var roof_turret_pos = get_parent().get_node("roof_turret_pos")
onready var missile_launcher_pos = get_parent().get_node("missile_launcher_pos")
onready var mine_dispenser_pos = get_parent().get_node("mine_dispenser_pos")

# The Combat Controller need to be added to the scene in order to work
func _ready():
	# Setup medium range detection
	get_parent().get_node("range_medium").connect("body_enter", self, "_on_range_medium_body_enter")
	get_parent().get_node("range_medium").connect("body_exit", self, "_on_range_medium_body_exit")
	
	# TODO: Add front guns
	# ...
	
	# Node name
	set_name("combat_controller") 
	
	# Enable user input
	set_process_input(true) 

func _process(delta):
	# Adds a pickup delay that is enabled when we have
	# dropped a weapon suddenly: prevents accidental 
	# firing.
	if(weapon_change_delay <= WEAPON_CHANGE_DELAY):
		weapon_change_delay += delta

# User Input
func _input(event):
	# Shoot main weapon
	if(event.is_action_pressed("fire1")):
		print("Shoot main weapons")
	elif(event.is_action_released("fire1")):
		print("Stop shooting main weapons")
	
	# Shoot special weapon
	if(event.is_action_pressed("fire2")):
		print("Shoot secondary weapons")
	elif(event.is_action_released("fire1")):
		print("Stop shooting main weapons")

# When the player attempts to load a weapon
func load_weapon(weapon_instance):
	# Prev current weapon index
	# We set it by default to 0, because if you have no previous weapons
	# we make sure to set it to be the first
	var prev_index = 0
	
	# Used to control whether or not we want to set the added weapon as current
	# This may be set to true later on
	var replacing = false
	
	# Check if we already have the weapon
	for weapon in equipped_weapons:
		# We have the same weapon already
		if(weapon.id == weapon_instance.id):
			if(!weapon_instance.unlimited_ammo): 
				# Fill up the ammo
				weapon.ammo_count = clamp(weapon.ammo_count + weapon_instance.ammo_count, 1, weapon.max_ammo)
				
				#  TODO: Find and replace the signal with something more descriptive
				emit_signal("weapon_shot")
			return true
	
	# ----- Drop the weapon we already HAD selected
	# If we can no longer equip more weapons
	if(equipped_weapons.size() == MAX_WEAPON_COUNT):
		# Drop selected weapon on the ground and replace it with the new one
		
		# Get the index of current weapon
		prev_index = equipped_weapons.find(current_weapon)
		
		# Drop a weapon pickup # <---- 
		current_weapon.drop_weapon()
		
		# Remove weapon from everything 
		# current_weapon.deconstruct()
		
		# Enable replacement, since we can no longer have more weapons
		replacing = true
	
	# ----- Get the weapon that we picked up
	# Add the new weapon
	if(weapon_instance.id == Weapon.ROOF_TURRET):
		roof_turret_pos.add_child(weapon_instance)
		weapon_instance.init(targets) # the roof turret needs to know about nearby targets
	elif(weapon_instance.id == Weapon.MISSILE_LAUNCHER):
		missile_launcher_pos.add_child(weapon_instance)
	elif(weapon_instance.id == Weapon.MINE_DISPENSER):
		weapon_instance.player = self # TEMP Solution
		mine_dispenser_pos.add_child(weapon_instance)
	else:
		# What? This should never happen... !
		return false
	
	# If we are replacing the selected weapon, or 
	if(replacing):
		equipped_weapons[prev_index] = weapon_instance
		# Notify about new selected weapon
		emit_signal("weapon_selected", current_weapon)
	else:
		equipped_weapons.append(weapon_instance)
	
	# If we are replacing the selected weapon, or 
	# if we have just added our first weapon,
	# we then set that to be the current weapon
	if(replacing || equipped_weapons.size() == 1):
		emit_signal("weapon_changed", equipped_weapons)
		current_weapon = weapon_instance
		emit_signal("weapon_selected", current_weapon)
	
	# Notify change to whomever is listening
	# emit_signal("weapon_changed", equipped_weapons)
	
	# Return true to notify about our success
	return true


# Gets rid of the weapon completely.
# When a weapon has been dropped we also add a delay to prevent
# accidental firing
func weapon_dropped(weapon_instance):
	# Remove the weapon from array
	equipped_weapons.erase(weapon_instance)
	
	# Remove the weapon as a child
	print("BEFORE FREEING WILLY")
	weapon_instance.free()
	print("AFTER: " + str(weapon_instance.get_name()))
	# Change to a different weapon
	if(equipped_weapons.size() == 0):
		current_weapon = null
	else:
		# Start the delay by setting it to 0
		weapon_change_delay = 0
		
		# Change to a prev weapon
		prev_weapon()
	
	# Notify about the change
	emit_signal("weapon_changed", equipped_weapons)# Nearby enemies (used to inform certain weapons when they are initialized)

# Nearby Targets
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

