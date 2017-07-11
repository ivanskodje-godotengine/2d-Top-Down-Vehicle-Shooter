extends Container

export (Vector2) var max_sprite_size = Vector2(200, 200)

func set_texture(tex):
	tex.set_size_override(Vector2(200, 200))
	get_node("sprite_character").set_texture(tex)