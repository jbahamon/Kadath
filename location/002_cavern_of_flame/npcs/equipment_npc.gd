extends FlagSetterNPC


const NID_AFTER_GIVING_EQUIPMENT = 6

func on_player_interaction(proxy: PlayerProxy):
	var was_flag_on = VarsService.get_flag(self.flag)
	super.on_player_interaction(proxy)
	if not was_flag_on and VarsService.get_flag(self.flag) and\
	 	self.dialog_nid != NID_AFTER_GIVING_EQUIPMENT:
		
		var inventory: Inventory = EntitiesService.get_party().inventory
		inventory.add("leather_cap")
		inventory.add("leather_armor")
		inventory.add("stick")

	self.dialog_nid = NID_AFTER_GIVING_EQUIPMENT
