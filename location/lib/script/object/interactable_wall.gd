extends Area2D

signal player_interaction(proxy)

func on_player_interaction(proxy: PlayerProxy):
	emit_signal("player_interaction", proxy)
