extends Node2D

var orientations = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for spot in self.get_children():
		orientations[NodePath(spot.name)] = VarsService.round_orientation_with_bias(-spot.position)
