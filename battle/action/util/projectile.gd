extends AnimatedSprite2D

var speed = Vector2.ZERO

func _ready() -> void:
	self.set_process(false)
	
func _process(delta):
	position += delta * speed
