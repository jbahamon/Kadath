extends Control

func set_icon(frames: SpriteFrames):
	var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
	animated_sprite.sprite_frames = frames
	animated_sprite.play(&"default")
	
