extends BaseNPC

func _ready():
	if not Inventory.has("amulet"):
		dialog_name = "kaman_thah_pre_amulet"
	else:
		dialog_name = "kaman_thah_post_amulet"
	
	
	
func on_player_interaction(player: Player):
	.on_player_interaction(player)
	if Inventory.has("amulet"):
		# initiate battle choice
		pass
