extends StaticBody2D

class_name InteractableObject

signal player_interaction

func on_player_interaction(_proxy: PlayerProxy):
	emit_signal("player_interaction")

