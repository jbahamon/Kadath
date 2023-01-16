extends TileMap

class_name LocationRoom

export (Color) var clear_color = Color.black


func on_enter():
	pass

func get_local_scene():
	return self.get_node('../../')
