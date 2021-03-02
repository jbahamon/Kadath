extends FSMState

const TIMEOUT_S = 1.2
const speed = 21
var instance = null
	
func _process(fsm, _delta):
	if fsm.state_time > TIMEOUT_S:
		self.on_timeout(fsm)

	
func _physics_process(fsm, _delta):
	var _resulting_velocity = fsm.move_and_slide(fsm.facing * speed)

	
func enter(fsm):
	fsm.set_animation("move")

	
func on_timeout(fsm):
	fsm.change_state("idle")
