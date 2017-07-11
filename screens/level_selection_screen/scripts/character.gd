extends Node2D

onready var tween = get_parent().get_node("level_selection_tween")
var is_moving = false

func _ready():
	# Load A Mini PLayer
	var character = global.selected_character
	get_node("sprite").set_texture(character.vehicle.image_body)
	
	
	tween.connect("tween_start", self, "move_start")
	tween.connect("tween_complete", self, "move_complete")


# Move the Character to the next level (given the position of that level)
func move_to(to_pos):
	print("Beginning to move!")
	is_moving = true
	var time_to_move = 1.0 # seconds
	
	tween.interpolate_property(
	self, 
	"transform/pos", 
	get_pos(), 
	to_pos, 
	time_to_move, Tween.TRANS_SINE, Tween.EASE_IN)
	tween.start()


func move_start(object, key):
	# Prevent the player from changing levels while the tween is active
	print("Starting tween")
	pass

func move_complete(object, key):
	# Re-enable level changing ability
	print("Tween completed!")
	is_moving = false
	pass


func is_moving():
	return is_moving