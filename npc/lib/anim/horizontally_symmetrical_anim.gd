extends Marker2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

func play_anim(anim_name: String) -> void:
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)

func set_orientation(_orientation: Vector2) -> void:
	pass
