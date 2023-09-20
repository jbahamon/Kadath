enum Type {
	SET_ROOM,
	SET_OVERLAY,
	FADE_OVERLAY,
	
	SET_CAMERA,
	MOVE_CAMERA,
	ASSIGN_CAMERA,
	SHAKE,
	
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
	NARRATE,
	
	SIMULTANEOUS,
	SEQUENTIAL,
	END,
	WAIT,
	
	CALL
}

func execute(_tree: SceneTree):
	pass

func run(tree: SceneTree):
	await self.execute(tree)

func _to_string():
	return "generic instruction"
