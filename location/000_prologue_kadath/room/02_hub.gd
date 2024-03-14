extends LocationRoom

func on_enter():
	if VarsService.get_flag('kadath.left_barrier'):
		$LeftBarrier.queue_free()
	if VarsService.get_flag('kadath.right_barrier'):
		$RightBarrier.queue_free()
		
