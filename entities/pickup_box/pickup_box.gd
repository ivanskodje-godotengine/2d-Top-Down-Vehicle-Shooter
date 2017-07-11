tool
extends Node2D

# TODO: Create a generic Item that will allow you to add any Item to a pickup box
# This is just for convenience when working on levels with item placements

# Pickup Item
export (PackedScene) var item setget set_item
var pickup_item = null

# Is the item enabled?
var is_enabled = false

# Can the item respawn?
export (bool) var can_respawn = true

# Respawn time in seconds
export (int) var respawn_time = 10

# Can the item expire?
export (bool) var can_expire = false

# Expire time in seconds
export (int) var expire_time = 60

# Weapon Sticker Node
onready var weapon_sticker = get_node("wooden_crate/item_sticker")

# Timer respawn
var _timer_respawn = null

# Timer expire
var _timer_expire = null

const PICKUP_DELAY = 1.0 # seconds

# Used by tool to view the weapon in the EDITOR
func set_item(value):
	if(value != null):
		item = value
		pickup_item = value.instance()
		update_weapon()

func remove_delay(timer):
	# Enable user pickup
	is_enabled = true
	# Destroy the timer!
	timer.queue_free()

# Start
func _ready():
	# On spawn, add a delay before anyone can pick it up!
	var temp_timer = Timer.new()
	temp_timer.set_wait_time(PICKUP_DELAY)
	temp_timer.set_one_shot(true)
	temp_timer.connect("timeout", self, "remove_delay", [temp_timer])
	add_child(temp_timer)
	temp_timer.start()
	
	# Update weapons
	update_weapon()
	
	# If we can respawn, create respawn timer
	if(can_respawn):
		_timer_respawn = Timer.new()
		_timer_respawn.set_wait_time(respawn_time)
		_timer_respawn.set_one_shot(true)
		_timer_respawn.connect("timeout", self, "respawn")
		add_child(_timer_respawn)
	
	# If we can expire, create expiration timer
	if(can_expire):
		_timer_expire = Timer.new()
		_timer_expire.set_wait_time(expire_time)
		_timer_expire.set_one_shot(true)
		_timer_expire.connect("timeout", self, "expired")
		add_child(_timer_expire)
		_timer_expire.start()


# When the respawn timer has run out, we respawn
func respawn():
	# Enable 
	is_enabled = true
	
	# Show it
	show()

# When the expiration timer has expired, we get rid of ourselves
func expired():
	# Completely get rid of this item
	queue_free()


# This is run by the tool and when we begin, and will update the pickup box 
# to match the selected weapon (enum selection)
func update_weapon():
	print("update_weapon")
	if(get_node("wooden_crate/item_sticker") != null):
		# TODO: Make it more verbose (what is 0? what is 1? etc.)
		# Roof Turret
		if(pickup_item.id == 0):
			var texture = load("res://entities/pickups/weapons/roof_turret/assets/roof_turret_sticker.png")
			get_node("wooden_crate/item_sticker").set_texture(texture)
		# Missile Launcher
		elif(pickup_item.id == 1):
			var texture = load("res://entities/pickups/weapons/missile_launcher/assets/missile_launcher_sticker.png")
			get_node("wooden_crate/item_sticker").set_texture(texture)
		# Mine Dispenser
		elif(pickup_item.id == 2):
			var texture = load("res://entities/pickups/weapons/mine_dispenser/assets/mine_dispenser_sticker.png")
			get_node("wooden_crate/item_sticker").set_texture(texture)


# Run by tool and on startup, expects a weapon instance 
# that inherits generic_weapon.gd
func _set_weapon(item_instance):
	pickup_item = item_instance
	update_weapon()


# Epects a weapon instance that inherits generic_weapon.gd
func set_weapon(item_instance):
	print("C01")
	# TODO: Why do we use two set_weapons, when you can use one.. ?
	pickup_item = item_instance
	# update_weapon()

# Check if a player has hit me
func _on_area_2d_body_enter( body ):
	# If the pickup is not activated, return!
	if(!is_enabled):
		return
	
	# Get all groups
	var groups = body.get_groups()
	
	# If what entered was a player
	if(groups.has("player")):
		# Load weapon
		if(body.combat_controller.load_weapon(pickup_item)):
			# If I can expire, it means I will be gone forever!
			if(can_expire):
				queue_free()
				return
			
			# Since we cannot expire, we want to respawn at some point
			is_enabled = false
			
			# Hide from sight!
			hide()
			
			# Start a respawn timer
			if(can_respawn):
				_timer_respawn.start()