extends Control

# Animation Player
export (NodePath) var anim_player_path
onready var anim_player = get_node(anim_player_path)

# Sample Player
export (NodePath) var sample_player_path
onready var sample_player = get_node(sample_player_path)

# Next Scene
export (PackedScene) var next_scene


# Start
func _ready():
	debug()
	return
	if(!global.debug):
		# An animated delay
		anim_player.play("delay")
		
		# Wait for delay to complete
		yield(anim_player, "finished")
		
		# Play "wooosh" sound
		sample_player.play("wind")
		
		# Start fading
		anim_player.play("splash_fade")
		
		# Wait for fading to complete before continuing
		yield(anim_player, "finished")
		
		# Swap scene
		swap_scene()
	else:
		debug()


# Swap scene to the next scene
func swap_scene():
	# Create new menu instance
	var scene = next_scene.instance()
	
	# Add to parent
	get_parent().call_deferred("add_child", scene)
	
	# Destroy self
	self.queue_free()


# If debugging is enabled, we will skip ahead 
# since we would not want to view the splash screen 
# every time we want to test the game
func debug():
	# Create menu instance (which will replace splash)
	swap_scene()