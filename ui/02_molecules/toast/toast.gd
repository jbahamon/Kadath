extends Node2D

@export var rise_length = 96

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func show_toast(text, color: Color = Color.WHITE):
	label.modulate = color
	label.text = text
	
	
	label.position.y = 0
	
	var tween = get_tree().create_tween()
	tween.tween_property(self.label, "position:y", -rise_length, 0.75).\
		set_trans(Tween.TRANS_EXPO).\
		set_ease(Tween.EASE_OUT)
	animation_player.play("toast")
	await animation_player.animation_finished
