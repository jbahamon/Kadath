extends InteractableObject

export (Texture) var switched_on_texture

onready var sprite: Sprite = $Sprite

func turn_on():
	self.sprite.texture = switched_on_texture

