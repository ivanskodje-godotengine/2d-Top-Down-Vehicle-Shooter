extends Control

# Used to control debug functions & variables
export (bool) var debugging = false

func _enter_tree():
	# This is run before ready
	global.debug = debugging