extends BaseNPC

class_name FlagSetterNPC

export var flag: String

func on_player_interaction(player_proxy: PlayerProxy):
	.on_player_interaction(player_proxy)
	PlayerVars.set_flag(flag, true)
	
