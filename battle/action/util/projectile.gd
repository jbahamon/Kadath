extends AnimatedSprite2D

var speed = Vector2.ZERO

func _process(delta):
	position += delta * speed
