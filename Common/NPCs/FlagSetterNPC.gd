extends BaseNPC

class_name FlagSetterNPC

export(preload("res://Globals/PlayerVars.gd").Flags) var flag: int = 0

func on_player_interaction(player: Player):
	.on_player_interaction(player)
	PlayerVars.set_flag(flag, true)
	
