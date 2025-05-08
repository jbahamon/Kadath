extends LocationRoom


func on_enter():
	
	if not VarsService.get_flag('kadath.entrance.intro'):
		VarsService.set_flag('kadath.entrance.intro', true)
		$SouthGate.monitoring = false
		await CutsceneService.play_cutscene_from_file('res://location/000_prologue_kadath/cutscene/intro.txt')
		# We skip a couple physics frames to avoid detecting the player in the push zone when skipping the cutscene
		await get_tree().physics_frame
		await get_tree().physics_frame
		$SouthGate.monitoring = true
		EntitiesService.proxy.set_mode(PlayerProxy.ProxyMode.GAMEPLAY)
	
