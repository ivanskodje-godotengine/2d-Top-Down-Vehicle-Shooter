extends Node

# Used to control debug functions & variables
var debug = false # Default false

enum { ROOF_TURRET, MISSILE_LAUNCHER }

# Configuration
var config = {
	screen_width = 1920,
	screen_height = 1080,
	music = {
		current = 0,
		total = 100
	}
}

# Selected character
var selected_character = null

class Vehicle:
	var name = ""
	var image_body = Texture
	var speed = 1
	var acceleration = 1

class Character:
	var name = ""
	var image = Texture
	var vehicle = Vehicle.new()

var character_array = []