extends StaticBody2D

class_name InteractableObject

signal player_interaction(proxy)

func on_player_interaction(proxy: PlayerProxy):
	emit_signal("player_interaction", proxy)

