extends BaseNPC

class_name FlagSetterNPC

export(preload("res://globals/player_vars.gd").Flags) var flag: int = 0

func on_player_interaction(player_proxy: PlayerProxy):
	.on_player_interaction(player_proxy)
	PlayerVars.set_flag(flag, true)
	
