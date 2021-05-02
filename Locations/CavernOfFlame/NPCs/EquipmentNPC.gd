extends FlagSetterNPC

const NID_AFTER_GIIVNG_EQUIPMENT = 6

func on_player_interaction(player: Player):
	var was_flag_on = PlayerVars.get_flag(self.flag)
	.on_player_interaction(player)
	if not was_flag_on and PlayerVars.get_flag(self.flag) and\
	 	self.dialog_nid != NID_AFTER_GIIVNG_EQUIPMENT:
		PlayerVars.inventory.add_item("leather_cap")
		PlayerVars.inventory.add_item("leather_armor")
		PlayerVars.inventory.add_item("wooden_staff")

	self.dialog_nid = NID_AFTER_GIIVNG_EQUIPMENT
