extends TileMap

class_name LocationRoom

func on_enter():
	pass

func get_local_scene():
	return self.get_node('../../')
