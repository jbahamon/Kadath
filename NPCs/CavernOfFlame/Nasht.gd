extends BaseNPC

func _ready():
	if not Inventory.has("amulet"):
		dialog_name = "nasht_pre_amulet"
	else:
		dialog_name = "nasht_post_amulet"
	
	
	
func on_player_interaction(player: Player):
	.on_player_interaction(player)
	if not Inventory.has("amulet"):
		Inventory.add_item("amulet")
		dialog_name = "nasht_post_amulet"
