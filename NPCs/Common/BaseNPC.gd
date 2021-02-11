extends KinematicBody2D

class_name BaseNPC


export (String) var npc_name
export (Texture) var sprite_sheet
export (int) var hframes = 4
export (int) var vframes = 5
export (Vector2) var sprite_offset = Vector2(12, 33)


onready var sprite: Sprite = $Sprite


func _ready():
	sprite.texture = sprite_sheet
	sprite.hframes = hframes
	sprite.vframes = vframes
	sprite.offset = -sprite_offset


func _on_InteractableArea_interacted_with():
	emit_signal("talk")

