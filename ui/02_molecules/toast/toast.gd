extends Node2D

@export var rise_length = 16

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func show_toast(text: String, color: Color = Color.WHITE):
	label.modulate = color
	label.text = text
	
	label.position.y = 0
	
	var tween = get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self.label, "position:y", -rise_length, 0.5)
	animation_player.play("toast")
	return animation_player.animation_finished
