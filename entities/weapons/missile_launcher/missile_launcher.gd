extends "res://entities/weapons/generic_weapon.gd"

# Bullet Spawn Position
onready var bullet_spawn1 = get_node("bullet_spawn1")

# Weapon active?
var is_enabled = true # turns to false when changing to another weapon

# Start 
func _ready():
	set_process_input(true)


# Update the bullet position
func update_bullet_pos(bullet):
	# Set bullet spawn
	bullet.set_global_pos(bullet_spawn1.get_global_pos())