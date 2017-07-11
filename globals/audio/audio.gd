extends CanvasLayer
# Music Volume
var music_volume = 0 setget set_music_volume

# Sound Effect Volume
var sfx_volume = 0 setget set_sfx_volume

# Sample Player
onready var sample_player = get_node("sample_player_2d")

# Music player
onready var stream_player = get_node("stream_player")


# Play sound effect
func play_sfx(sfx):
	sample_player.play(sfx)


# Stop playing sound effects
func stop_sfx():
	sample_player.stop_all()


# Play music
func play_music(music_path, loop = true):
	stream_player.set_stream(music_path)
	stream_player.set_loop(loop)
	stream_player.play()


# Stop playing music
func stop_music():
	stream_player.stop()


# Pause music
func pause_music():
	stream_player.set_paused(true)


# Resume music
func resume_music():
	stream_player.set_paused(false)


# Set music volume
func set_music_volume(value):
	music_volume = clamp(value, 0, 100)
	stream_player.set_volume(music_volume/100)


# Set SFX volume
func set_sfx_volume(value):
	sfx_volume = clamp(value, 0, 100)
	sample_player.voice_set_volume_scale_db(2, 0)


# Start
func _ready():
	set_music_volume(music_volume)
	set_sfx_volume(sfx_volume)