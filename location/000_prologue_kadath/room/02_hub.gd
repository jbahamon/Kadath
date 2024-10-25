extends LocationRoom

const LEFT_CIRCUIT_LAYER = 3
const RIGHT_CIRCUIT_LAYER = 4
const POOL_LAYER = 5

func setup():
	if VarsService.get_flag('kadath.left_barrier'):
		self.set_layer_enabled(LEFT_CIRCUIT_LAYER, true)
		$Statue.play("flowing-empty")
		
	if VarsService.get_flag('kadath.right_barrier'):
		self.set_layer_enabled(RIGHT_CIRCUIT_LAYER, true)
		$Statue2.play("flowing-empty")
	
	if VarsService.get_flag('kadath.left_barrier') and VarsService.get_flag('kadath.right_barrier'):
		self.set_layer_enabled(POOL_LAYER, true)
		$Barrier.queue_free()
		$Statue.play("flowing-full")
		$Statue2.play("flowing-full")
		$Bridge.visible = true
		
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
