extends Node

class_name NPCMovement

@onready var parent = get_parent()

func _process(_delta):
	pass

func _physics_process(_delta):
	pass
	
func start():
	self.parent.play_anim("idle")
	self.set_process(true)

func stop():
	self.set_process(false)
