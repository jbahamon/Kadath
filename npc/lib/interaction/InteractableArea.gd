extends Area2D

@onready var parent = get_parent()


func on_player_interaction(proxy: PlayerProxy):
	parent.on_player_interaction(proxy)
	
