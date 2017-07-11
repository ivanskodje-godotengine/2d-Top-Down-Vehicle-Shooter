extends KinematicBody2D

export (int, "One", "Two") var pickup_num

func _ready():
	if(!global.debug):
		if(pickup_num == 0):
			set_pos(Vector2(4505, get_pos().y))
		elif(pickup_num == 1):
			set_pos(Vector2(5505, get_pos().y))