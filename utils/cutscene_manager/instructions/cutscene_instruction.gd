class_name CutsceneInstruction

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
	
	SET_MUSIC,
	SET_POSITION,
	LOOK,
	LOOK_AT,
	
	MOVE,
	WALK,
	RUN,
	PLAY_ANIM,
	
	START_DIALOGUE,
	NARRATE,
	
	SIMULTANEOUS,
	SEQUENTIAL,
	END,
	WAIT,
	
	AWAIT,
	CALL
}

enum ExecutionMode {
	PLAY,
	SKIP
}
func execute(_tree: SceneTree, _mode: ExecutionMode):
	pass

func run(tree: SceneTree, mode: ExecutionMode):
	print(self)
	await self.execute(tree, mode)

func _to_string():
	return "generic instruction"

func skip(_tree: SceneTree):
	pass
	
func pause(_tree: SceneTree):
	pass

func resume(_tree: SceneTree):
	pass
