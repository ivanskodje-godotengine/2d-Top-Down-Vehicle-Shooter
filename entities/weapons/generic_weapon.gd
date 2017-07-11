extends Node2D

export (PackedScene) var bullet_scene

# Store bullets in memory
export (int) var max_bullets = 20

# Weapon ID
export (int) var id = -1

# Bullets in Memory
var inactive_bullets = {}
var active_bullets = {}

# Whether or not you are firing
var is_firing = false

# Number of ammo
export (bool) var unlimited_ammo = true
export (int, 0, 9999) var max_ammo = 30
var ammo_count = max_ammo

# Shot fired signal
signal shot_fired

# Start
func _ready():
	# Allowing you to shoot immediately before the "timer" kicks in
	time_shot = bullet_delay
	
	# Processing
	set_fixed_process(true)

# Controller for bullet delay
export (float, 0, 10, 0.1) var bullet_delay = 0.1 # seconds
var time_shot = bullet_delay

# Processing
func _fixed_process(delta):
	time_shot += delta

# Controller for creating the bullets on first shot
var bullets_added = false
func add_bullets():
	# Generate bullets
	for i in range(0, max_bullets):
		var new_bullet = bullet_scene.instance()
		new_bullet.init(self) # TODO: Try Signals
		new_bullet.set_name("bullet_" + str(i+1).pad_zeros(2))
		get_tree().get_root().get_node("/root/level/projectiles").add_child(new_bullet) # Just add it somewhere (for now)
		#inactive_bullets.append(new_bullet)
		inactive_bullets[new_bullet.get_name()] = new_bullet
		
# Shoot
func shoot():
	if(time_shot >= bullet_delay):
		time_shot = 0.0 # Reset delay
		
		# Add bullets to memory (only once)
		if(!bullets_added):
			add_bullets()
			bullets_added = true
		
		# Get bullet from inactive bullets
		if(inactive_bullets.size() > 0):
			var bullet_key = null
			var bullet = null
			
			# Get first key
			if(inactive_bullets.size() > 0):
				bullet_key = inactive_bullets.keys()[0]
				bullet = inactive_bullets[bullet_key]
				inactive_bullets.erase(bullet_key)
			else:
				return
			
			# Set bullet to active
			active_bullets[bullet_key] = bullet
			
			# Overwritten by the weapon
			update_bullet_pos(bullet)
			
			# Set the direction
			bullet.set_global_rot(get_global_rot())
			
			# Shoot.
			bullet.shoot()
			
			# Return true
			return true
	return false


# OVERWRITE IN WEAPON INSTANCE
func update_bullet_pos(bullet):
	pass

# Set Auto Fire
func set_firing(firing):
	is_firing = firing


# Disable bullet
func disable_bullet(bullet):
	active_bullets.erase(bullet.get_name())
	inactive_bullets[bullet.get_name()] = bullet

# Drops weapon on the ground (as a pickup)
func drop_weapon():
	# Create pickup instance
	var pickup = load("res://entities/pickup_box/pickup_box.tscn").instance()
	pickup.can_expire = true # Always on dropped weapons
	pickup.set_global_pos(get_global_pos())
	pickup.set_weapon(self)
	get_tree().get_root().get_node("/root/level").add_child(pickup)


# Used to safely remove our weapon from the scene
func deconstruct():
	# Commented out since we do not want to recreate 
	# the weapon instance, and instead reuse it
	
#	# Remove all bullets
#	for b in inactive_bullets:
#		inactive_bullets[b].queue_free()
#	
#	# Inform active bullets to terminate on exit
#	for b in active_bullets:
#		active_bullets[b].parent = null
	pass

	# queue_free()