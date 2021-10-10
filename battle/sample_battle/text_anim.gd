extends CharacterAnim

class_name TextAnim

func play_anim(anim_name: String) -> void:
	print("%s %s'd" % [ get_parent().name, anim_name])
	

func set_orientation(orientation: Vector2) -> void:
	pass
	
