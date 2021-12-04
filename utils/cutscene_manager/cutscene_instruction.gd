class_name CutsceneInstruction

enum Type {
	SET_OVERLAY,
	FADE_OVERLAY,
	SET_CAMERA,
	MOVE_CAMERA,
	NPC_WALK,
	OPEN_DIALOG,
	SIMULTANEOUS,
	SEQUENTIAL,
	END
}

var type: int
var args: Dictionary
