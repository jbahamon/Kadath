extends Position2D

class_name CharacterAnim

onready var animation_tree: AnimationTree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")


func play_idle() -> void:
	animation_state.travel("idle")
	

func play_on_movement(velocity: Vector2) -> void:
	if velocity == Vector2.ZERO:
		animation_state.travel("idle")
	else:
		animation_state.travel("walk")


func update_orientation(orientation: Vector2) -> void:

	self.animation_tree["parameters/idle/blend_position"] = orientation
	self.animation_tree["parameters/walk/blend_position"] = orientation
	
	
