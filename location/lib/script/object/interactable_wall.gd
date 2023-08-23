extends Area2D

signal player_interaction

func on_player_interaction(_proxy: PlayerProxy):
	emit_signal("player_interaction")
