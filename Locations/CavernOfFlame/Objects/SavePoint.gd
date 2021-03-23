extends StaticBody2D


func on_player_interaction(_player: Player):
	get_local_scene().show_save_menu()

func get_local_scene():
	return get_node("../../../")
