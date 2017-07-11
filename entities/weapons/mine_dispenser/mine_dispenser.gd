extends Node2D

# TODO: Make this inherit the generic weapon.gd (or create something better)
export (int) var id = -1

# Bullet/Weapon you send out
export (PackedScene) var mine_scene

# Bullet Spawn Position
onready var bullet_spawn1 = get_node("bullet_spawn1")

# Player (set by player)
var player = null

# TODO: Do something already gggggggggg
export (bool) var unlimited_ammo = false

# Whether or not you are firing
var is_firing = false

# Number of ammo
export (int, 0, 9999) var max_ammo = 6
var ammo_count = max_ammo

# Start
func _ready():
	# Allowing you to shoot immediately before the "timer" kicks in
	time_shot = bullet_delay
	
	# Processing
	set_fixed_process(true)

# Controller for bullet delay
export (float, 0, 10, 0.1) var bullet_delay = 2 # seconds
var time_shot = bullet_delay

# Processing
func _fixed_process(delta):
	if(time_shot <= bullet_delay):
		time_shot += delta


# Shoot
# var left_barrel = true
func shoot():
	if(time_shot >= bullet_delay):
		time_shot = 0.0 # Reset delay
		
		# Instance mine
		var mine_instance = mine_scene.instance()
		
		# Place on ground (on spawn)
		mine_instance.set_global_pos(get_global_pos())
		get_tree().get_root().get_node("/root/level/projectiles").add_child(mine_instance)
		
		# Decrease ammo
		ammo_count -= 1
		
		if(ammo_count <= 0):
			# Inform player that we are going away for a while
			player.weapon_dropped(self)
			
			# Be gone
			deconstruct()
		
		return true
	return false


# Set Auto Fire
func set_firing(firing):
	is_firing = firing


# Drops weapon on the ground (as a pickup)
func drop_weapon():
	# Create pickup instance
	var pickup = load("res://entities/pickup_box/pickup_box.tscn").instance()
	pickup.can_expire = true # Always on dropped weapons
	pickup.set_global_pos(get_global_pos())
	pickup.set_weapon(self)
	get_tree().get_root().get_node("/root/level").add_child(pickup)


# TODO: Create a universal weapon script 
# (that has this among other features that are absolute in all weapons)
func deconstruct():
	# Remove self
	queue_free()