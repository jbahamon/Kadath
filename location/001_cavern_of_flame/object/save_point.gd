extends StaticBody2D

@export var save_spot_name = "Somewhere"

func on_player_interaction(_player_proxy: PlayerProxy):
	UIService.show_save_menu(save_spot_name)
