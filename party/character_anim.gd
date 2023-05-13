extends Marker2D

class_name CharacterAnim

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")

func play_anim(anim_name: String) -> void:
	animation_state.travel(anim_name)

func set_orientation(orientation: Vector2) -> void:
	self.animation_tree["parameters/idle/blend_position"] = orientation
	self.animation_tree["parameters/walk/blend_position"] = orientation
