extends LocationRoom

func setup():
	if VarsService.get_flag('kadath.left_barrier'):
		$LeftBarrier.queue_free()
	if VarsService.get_flag('kadath.right_barrier'):
		$RightBarrier.queue_free()
		
	if EntitiesService.get_party().is_unlocked(PartyMember.Id.PICKMAN):
		$JoinTrigger.monitoring = false
		$NPCPickman.queue_free()
		
func spawn_pickman():
	$NPCPickman.visible = true
	$NPCPickman.global_position.x = EntitiesService.get_proxy().global_position.x

func unlock_pickman():
	$JoinTrigger.monitoring = false
	EntitiesService.get_party().set_unlocked(PartyMember.Id.PICKMAN, true)
	EntitiesService.get_party().reset_movement()
	
func _on_join_trigger_body_entered(_body):
	CutsceneService.play_cutscene_from_file("res://location/000_prologue_kadath/cutscene/catch_up.cutscene")
