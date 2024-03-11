extends Node

class_name NPCMovement

@onready var parent = get_parent()

func _physics_process(delta):
	pass
	
func start():
	self.parent.play_anim("idle")
	self.set_process(true)

func stop():
	self.set_process(false)
