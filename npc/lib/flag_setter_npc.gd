extends BaseNPC

class_name FlagSetterNPC

@export var flag: String

func on_player_interaction(player_proxy: PlayerProxy):
	super.on_player_interaction(player_proxy)
	VarsService.set_flag(flag, true)
	
