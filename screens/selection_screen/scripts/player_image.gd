extends Sprite

# Make sure the texture does not exceed parent container
func _on_player_image_texture_changed():
	# Get image size
	var size_vector2 = get_texture().get_size()
	
	# Ratio
	var ratio = 0
	
	# If texture height is greater than the parent, set to fit parent
	if(size_vector2.y > get_parent().get_size().y):
		# Update ratio
		ratio = get_parent().get_size().y / size_vector2.y
		
		# Fit height to parent height
		size_vector2.y = get_parent().get_size().y
		
		# Fit width to match aspect ratio
		size_vector2.x *= ratio
	
	# If texture width is greater than the parent, set to fit parent
	if(size_vector2.x > get_parent().get_size().x):
		# Update ratio
		ratio = get_parent().get_size().x / size_vector2.x
		
		# Fit height to parent height
		size_vector2.x = get_parent().get_size().x
		
		# Fit width to match aspect ratio
		size_vector2.y *= ratio
	
	# Set texture size
	get_texture().set_size_override(size_vector2)
