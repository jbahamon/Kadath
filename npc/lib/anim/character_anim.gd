extends Marker2D

@export var animation_names: PackedStringArray
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")

var blend_position_names: Array
func _ready():
	self.blend_position_names = []
	
	for animation_name in self.animation_names:
		self.blend_position_names.append("parameters/%s/blend_position" % animation_name)
		
func play_anim(anim_name: String) -> void:
	animation_state.travel(anim_name)

func set_orientation(orientation: Vector2) -> void:
	for blend_position_name in self.blend_position_names:
		self.animation_tree[blend_position_name] = orientation
