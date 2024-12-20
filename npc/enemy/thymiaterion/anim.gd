extends Marker2D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_state = animation_tree.get("parameters/playback")

var current_orientation: Vector2:
	get:
		return Vector2.DOWN

func play_anim(anim_name: String) -> void:
	animation_state.travel(anim_name)

func has_anim(anim_name: String) -> bool:
	return animation_tree.tree_root.has_node(anim_name)


func set_orientation(_orientation: Vector2) -> void:
	pass
