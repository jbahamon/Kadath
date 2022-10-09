enum Type {
	SET_ROOM,
	SET_OVERLAY,
	FADE_OVERLAY,
	
	SET_CAMERA,
	MOVE_CAMERA,
	ASSIGN_CAMERA,
	
	HIDE,
	SHOW,
	
	DISABLE_COLLISIONS,
	ENABLE_COLLISIONS,
	
	ASSIGN_PROXY,
	
	SET_POSITION,
	LOOK,
	LOOK_AT,
	
	MOVE,
	WALK,
	PLAY_ANIM,
	
	START_DIALOG,
	
	SIMULTANEOUS,
	SEQUENTIAL,
	END,
	WAIT,
	
	CALL
}

signal execution_finished

var finished: bool

func execute(cutscene_manager):
	pass

func run(cutscene_manager):
	self.finished = false
	print(self.str())
	var value = self.execute(cutscene_manager)
	
	if value != null:
		yield(value, "completed")
		
	self.finished = true
	emit_signal("execution_finished")

func str():
	return "generic instruction"
