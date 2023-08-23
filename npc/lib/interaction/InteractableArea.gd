extends Area2D

@onready var parent = get_parent()


func on_player_interaction(player):
	parent.on_player_interaction(player)
	
