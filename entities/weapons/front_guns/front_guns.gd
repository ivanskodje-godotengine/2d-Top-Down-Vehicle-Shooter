extends "res://entities/weapons/generic_weapon.gd"

# Bullet Spawn Posotions
onready var bullet_spawn1 = get_node("bullet_spawn1")
onready var bullet_spawn2 = get_node("bullet_spawn2")

var left_turret = false

# Update the bullet position
func update_bullet_pos(bullet):
	# Set bullet spawn
	if(left_turret):
		bullet.set_global_pos(bullet_spawn1.get_global_pos())
	else:
		bullet.set_global_pos(bullet_spawn2.get_global_pos())
	
	# Toggle
	left_turret = !left_turret