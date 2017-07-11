extends Node2D

# Camera Movement Speed (towards the right)
export (int) var camera_speed = 5

# Background Speed
export (float) var background_speed = 0.1

# Foreground 1 Speed
export (float) var foreground_1_speed = 0.3

# Road Speed
export (float) var road_speed = 1.0

# Foreground 2 Speed
export (float) var foreground_2_speed = 1.5

# Camera Node
export (NodePath) var camera_path
onready var camera = get_node(camera_path)

# Background ParallaxLayer
export (NodePath) var background_path
onready var background = get_node(background_path)

# Foreground 1 ParallaxLayer
export (NodePath) var foreground_1_path
onready var foreground_1 = get_node(foreground_1_path)

# Road ParallaxLayer
export (NodePath) var road_path
onready var road = get_node(road_path)

# Foreground 2 ParallaxLayer
export (NodePath) var foreground_2_path
onready var foreground_2 = get_node(foreground_2_path)


# Start
func _ready():
	# Enable processing for camera movement
	set_process(true)
	
	# Set initial speeds
	background.set_motion_scale(Vector2(background_speed, 0))
	foreground_1.set_motion_scale(Vector2(foreground_1_speed, 0))
	road.set_motion_scale(Vector2(road_speed, 0))
	foreground_2.set_motion_scale(Vector2(foreground_2_speed, 0))

# Processing - Moving camera towards the right
func _process(delta):
	var pos = camera.get_pos()
	camera.set_pos(Vector2(pos.x + camera_speed, pos.y))
