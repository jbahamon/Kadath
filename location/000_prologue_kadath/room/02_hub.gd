extends LocationRoom

func on_enter():
	if VarsService.get_flag('kadath.hub.left_barrier'):
		$LeftBarrier.queue_free()
	if VarsService.get_flag('kadath.hub.right_barrier'):
		$RightBarrier.queue_free()
		
	var party = EntitiesService.get_party()
	party.unlock(PartyMember.Id.PETERS)
		
		
