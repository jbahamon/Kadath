extends Node

class_name NPCMovement

onready var parent = get_parent()

func _process(_delta):
	pass

func walk_to(target: Vector2, speed: float):
	randomize()
	assert(speed > 0)
	var time = (parent.global_position - target).length()/speed
	self.set_process(false)
	parent.look_at(target)
	parent.animation_state.travel("walk")
	parent.velocity = (target - parent.global_position).normalized() * speed
	yield(get_tree().create_timer(time), "timeout")
	parent.velocity = Vector2.ZERO
	parent.animation_state.travel("idle")
	self.set_process(true)
	
