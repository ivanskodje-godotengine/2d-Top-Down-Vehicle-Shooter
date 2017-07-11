#	tool
#	extends Node2D
#	
#	# Weapon Selection 
#	# NB: Make sure it is in the same order as the global.ROOF_TURRET
#	export (int, "Roof Turret", "Missile Launcher", "Mine Dispenser") var weapon = 0 setget _set_weapon
#	
#	# This is needed in order to access globals - A workaround to use it with a tool script
#	onready var Weapon = get_node("/root/Weapon")
#	
#	# Ammo
#	var ammo = 0
#	
#	# Weapon Sticker
#	onready var weapon_sticker = get_node("wooden_crate/weapon_sticker")
#	
#	# Respawn Timer
#	onready var respawn_timer = get_node("respawn_timer")
#	
#	# Expire TImer
#	onready var expire_timer = get_node("expire_timer")
#	
#	# Active
#	var active = true
#	
#	# Expiration
#	var can_expire = false
#	
#	func _ready():
#		update_weapon()
#		
#		# If we can expire, we start a timer that will cause us to queue_free later
#		if(can_expire):
#			expire_timer.start()
#	
#	# This is run by the tool and when we begin, and will update the pickup box 
#	# to match the selected weapon (enum selection)
#	func update_weapon():
#		if(get_node("wooden_crate/weapon_sticker") != null):
#			# Roof Turret
#			if(weapon == 0):
#				var texture = load("res://entities/pickups/weapons/roof_turret/assets/roof_turret_sticker.png")
#				get_node("wooden_crate/weapon_sticker").set_texture(texture)
#			# Missile Launcher
#			elif(weapon == 1):
#				var texture = load("res://entities/pickups/weapons/missile_launcher/assets/missile_launcher_sticker.png")
#				get_node("wooden_crate/weapon_sticker").set_texture(texture)
#			# Mine Dispenser
#			elif(weapon == 2):
#				var texture = load("res://entities/pickups/weapons/mine_dispenser/assets/mine_dispenser_sticker.png")
#				get_node("wooden_crate/weapon_sticker").set_texture(texture)
#	
#	
#	# Run by tool and on startup
#	func _set_weapon(value):
#		weapon = value
#		update_weapon()
#	
#	# Set weapon remotely (does not interfere with tool)
#	func set_weapon(weapon_instance):
#		# TODO: Why not just send the same instance instead of storing weapon and ammo separately?
#		weapon = weapon_instance.id
#		ammo = weapon_instance.ammo_count
#		update_weapon()
#	
#	# Check if a player has hit me
#	func _on_area_2d_body_enter( body ):
#		# If the pickup is not activated, return!
#		if(!active):
#			return
#		
#		# Get all groups
#		var groups = body.get_groups()
#		
#		# If what entered was a player
#		if(groups.has("player")):
#			var weapon_id = null
#			
#			# A fix to make sure we always load the correct weapon ID,
#			# as we may not always add the weapons in "correct order"
#			# in the enum
#			if(weapon == 0): 
#				weapon_id = Weapon.ROOF_TURRET
#			elif(weapon == 1):
#				weapon_id = Weapon.MISSILE_LAUNCHER
#			elif(weapon == 2):
#				weapon_id = Weapon.MINE_DISPENSER
#			else:
#				return
#			
#			# Load weapon
#			if(body.combat_controller.load_weapon()):
#				# If we are a... leftover weapon - do not respawn
#				if(can_expire):
#					queue_free()
#				
#				# Hide from sight
#				active = false
#				hide()
#	
#				# Start a respawn timer
#				respawn_timer.start()
#	
#	
#	# Respawn
#	func _on_respawn_timer_timeout():
#		# Respawn!
#		active = true
#		show()
#	
#	
#	# When we have expired
#	func _on_expire_timer_timeout():
#		queue_free()
