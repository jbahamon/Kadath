extends Marker2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var current_orientation: Vector2:
	get:
		return Vector2.DOWN

func play_anim(anim_name: String) -> void:
	animation_player.play(anim_name)

func has_anim(anim_name: String) -> bool:
	return animation_player.has_animation(anim_name)


func set_orientation(_orientation: Vector2) -> void:
	pass
