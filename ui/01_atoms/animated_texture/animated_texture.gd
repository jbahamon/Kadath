extends TextureRect

@export var atlases: Array[AtlasTexture]
@export var time_per_frame: float = 1.0

var time = 0.0
var idx = 0

func _process(delta: float) -> void:
	time = fmod(time + delta, time_per_frame * atlases.size())
	if floor(time/time_per_frame) != idx:
		idx = (idx + 1) % atlases.size()
		self.texture = atlases[idx]
		
