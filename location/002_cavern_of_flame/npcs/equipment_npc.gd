extends FlagSetterNPC

var leather_cap = preload("res://item/equipment/leather_cap.tres")
var leather_armor = preload("res://item/equipment/leather_armor.tres")
var stick = preload("res://item/equipment/wooden_staff.tres")

const NID_AFTER_GIVING_EQUIPMENT = 6

func on_player_interaction(player_proxy: PlayerProxy):
	var was_flag_on = VarsService.get_flag(self.flag)
	super.on_player_interaction(player_proxy)
	if not was_flag_on and VarsService.get_flag(self.flag) and\
	 	self.dialog_nid != NID_AFTER_GIVING_EQUIPMENT:
		
		var inventory: Inventory = EntitiesService.get_party().get_inventory()
		inventory.add(leather_cap)
		inventory.add(leather_armor)
		inventory.add(stick)

	self.dialog_nid = NID_AFTER_GIVING_EQUIPMENT
