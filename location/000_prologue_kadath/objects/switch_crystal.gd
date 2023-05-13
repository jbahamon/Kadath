extends InteractableObject

@export var switched_on_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

func turn_on():
	self.sprite.texture = switched_on_texture

