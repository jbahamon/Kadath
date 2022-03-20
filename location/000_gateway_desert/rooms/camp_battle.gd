extends LocationRoom

func on_enter():
	var local_scene = self.get_local_scene()
	local_scene.start_battle(
		local_scene.get_party_battlers() + [$ShadowCritter/Battler]
	)
