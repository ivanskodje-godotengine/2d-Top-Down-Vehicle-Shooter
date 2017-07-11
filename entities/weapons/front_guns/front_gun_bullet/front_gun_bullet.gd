extends Node

export (int) var damage = 1
export (int) var speed = 10
var parent = null

# Start
func _ready():
	set_fixed_process(false)

# Bullet Movement
func _fixed_process(delta):
	set_pos(get_pos() + get_forward() * speed)

# Get forward direction
func get_forward():
	return Vector2(cos(get_rot() + PI/2.0), sin(get_rot() - PI/2.0))


# Init bullet
func init(parent):
	# Set parent reference
	self.parent = parent
	
	# Hide (Might have to do better)
	hide()

# Shooting the Bullet
func shoot():
	# Show bullet
	show()
	
	# Just do it
	set_fixed_process(true)


# Hide and cover until next shot
func _on_visibility_notifier_2d_exit_screen():
	parent.disable_bullet(self) 
	hide()
	set_fixed_process(false)