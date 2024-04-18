extends Area2D

signal player_interaction(proxy)

func on_player_interaction(proxy: PlayerProxy):
	self.player_interaction.emit(proxy)
