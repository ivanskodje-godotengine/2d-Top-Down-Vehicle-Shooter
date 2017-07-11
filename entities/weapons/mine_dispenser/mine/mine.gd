extends Area2D

# Damage
export (int) var damage = 1

# Active Mine
var active = false

# Delay
var delay = 0
const ACTIVATION_DELAY = 2 # sec

func _ready():
	set_process(true)

func _process(delta):
	delay += delta
	
	if(delay >= ACTIVATION_DELAY):
		active = true
		set_process(false)

# On body enter
func _on_mine_body_enter( body ):
	if(active):
		var groups = body.get_groups()
		
		if(groups.has("player")):
			# Boom does the dynamite
			# ...
			print("BOOM EFFECT!")
			
			# Apply damage to player
			# ...
			
			# Remove self when the animation is complete (if any)
			queue_free()