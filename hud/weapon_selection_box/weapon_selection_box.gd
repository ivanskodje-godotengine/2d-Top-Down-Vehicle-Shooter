extends Node2D

var color_selected = Color(1, 1, 0)
var color_unselected = Color(1, 1, 1)

# All weapons
var weapons = null

# Weapon texture
onready var weapon_texture = get_node("center_container/container_for_sprite/current_weapon")

# Current selected weapon
var selected_weapon

# Ammo 
onready var ammo = get_node("ammo")
const dots = 3 

# Start
func _ready():
	# Setup connection so that we get notified whenever weapons has changed
	get_tree().get_root().get_node("/root/level/player").connect("weapon_changed", self, "on_weapon_changed")
	get_tree().get_root().get_node("/root/level/player").connect("weapon_selected", self, "on_weapon_selected")
	get_tree().get_root().get_node("/root/level/player").connect("weapon_shot", self, "on_ammo_changed")


# Weapon change (added or removed a weapon)
func on_weapon_changed(weapon_array):
	# Store weapons if null
	if(weapons == null):
		weapons = weapon_array
	
	# Remove texture (if any) when we have no weapons
	if(weapons.size() == 0):
		weapon_texture.set_texture(null)
	
	# Get weapon count
	var weapon_count = weapon_array.size()
	
	# Show dots equal to number of weapons
	for i in range(1, dots+1):
		if(i <= weapon_count):
			# Show node
			get_node("weapon_dot_" + str(i)).show()
		else:
			get_node("weapon_dot_" + str(i)).hide()

# On weapon selected!
func on_weapon_selected(selected_weapon):
	# Set selected weapon image and dot
	for i in range(0, weapons.size()):
		# If this is our selected weapon, make it YELLOW!
		if(weapons[i] == selected_weapon):
			# Yellow
			get_node("weapon_dot_" + str(i+1)).set("modulate", color_selected)
			
			# Update the weapon image
			var texture = selected_weapon.get_node("sprite").get_texture()
			weapon_texture.set_texture(texture)
			
			# Set selected_weapon
			self.selected_weapon = selected_weapon
			
			# Handle ammo visibility
			if(selected_weapon.unlimited_ammo):
				ammo.hide()
			else:
				ammo.show()
				get_node("ammo").set_text("x " + str(selected_weapon.ammo_count))
		else:
			get_node("weapon_dot_" + str(i+1)).set("modulate", color_unselected)

# Runs whenever user has shot alt weapon
func on_ammo_changed():
	if(!selected_weapon.unlimited_ammo):
		ammo.set_text("x " + str(selected_weapon.ammo_count))