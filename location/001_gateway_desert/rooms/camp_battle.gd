extends LocationRoom

func on_enter():
	var critter = $ShadowCritter
	BattleService.start_battle(
		[$ShadowCritter], 
		critter.position
	)
