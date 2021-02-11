extends FSMState

const TIMEOUT_S = 1
	
func enter(fsm):
	fsm.set_animation("idle")
	
func _process(fsm, _delta):
	if fsm.state_time > TIMEOUT_S:
		self.on_timeout(fsm)
	
	
func on_timeout(fsm):
	if randi() % 2 == 0:
		fsm.change_state("move")
	else:
		fsm.state_time = 0
		if randi() % 2 == 0:
			make_turn(fsm)
	


func make_turn(fsm):
	var rotation_angle = PI/2.0
	if randi() % 2 > 0:
		rotation_angle = -rotation_angle
		
	fsm.rotate_facing(rotation_angle)
