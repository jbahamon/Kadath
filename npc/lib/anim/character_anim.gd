extends Marker2D

@export var animation_names: Array[String]  = ["idle", "walk"]
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var sprite: Sprite2D = $Sprite2D

var blend_position_names: Array

var current_orientation: Vector2:
	get:
		if self.blend_position_names.size() > 0:
			return self.animation_tree[self.blend_position_names[0]]
		else:
			return Vector2.DOWN
			
func _ready():
	self.blend_position_names = self.animation_names.map(
		func(animation_name): 
			return "parameters/%s/blend_position" % animation_name
	)

func play_anim(anim_name: String) -> void:
	animation_state.travel(anim_name)
	
func has_anim(anim_name: String) -> bool:
	return animation_tree.tree_root.has_node(anim_name)

func set_orientation(orientation: Vector2) -> void:
	for blend_position_name in self.blend_position_names:
		self.animation_tree[blend_position_name] = orientation

func get_current_anim():
	return self.animation_state.get_current_node()
