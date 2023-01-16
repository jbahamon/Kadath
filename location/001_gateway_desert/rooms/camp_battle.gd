extends LocationRoom

func on_enter():
	var local_scene = self.get_local_scene()
	var critter = $ShadowCritter
	local_scene.start_battle(
		[$ShadowCritter], 
		critter.position
	)
