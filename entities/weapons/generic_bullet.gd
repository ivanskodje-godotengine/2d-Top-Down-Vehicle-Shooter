extends Node

# Damage
export (int) var damage = 1

# Bullet speed
export (int) var speed = 50

# VisibilityNotifier2D - used to check when you have left the screen
export (NodePath) var visibility_notifier_path
onready var visibility_notifier = get_node(visibility_notifier_path)

# The weapon that shoot me
var parent = null


# Start
func _ready():
	# Setup signals
	visibility_notifier.connect("exit_screen", self, "_on_visibility_notifier_2d_exit_screen")
	
	# Enable processing
	set_fixed_process(false)


# Bullet Movement
func _fixed_process(delta):
	set_pos(get_pos() + get_forward() * speed)


# Get forward direction
var direction = Vector2(0, -1)
func get_forward():
	return Vector2(cos(get_global_rot() + PI/2.0), sin(get_global_rot() - PI/2.0))


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
# TODO: Might want to handle the bullets from outside the weapon itself... 
# Otherwise we will have trouble when we remove the weapon and we have bullets in memory, 
# as it does not queue_free itself.
func _on_visibility_notifier_2d_exit_screen():
	if(parent != null):
		parent.disable_bullet(self) 
		hide()
		set_fixed_process(false)
	else:
		queue_free()