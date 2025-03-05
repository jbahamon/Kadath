extends PanelContainer

@onready var text_label = $MarginContainer/HBoxContainer/RichTextLabel
@onready var indicator = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer
@onready var indicator_label = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/Label
func _ready():
	text_label.visible_ratio = 1
	set_advance_indicator_visibility(true)
	
func set_text(text: String):
	text_label.text = text
	text_label.visible_ratio = 0.0
	text_label.scroll_to_line(0)
	
func set_visible_ratio(ratio: float):
	text_label.visible_ratio = ratio

func set_advance_indicator_visibility(val: bool):
	if val:
		var advance_keycode = InputMap.action_get_events(&"ui_accept")[0].keycode
		var cancel_keycode = InputMap.action_get_events(&"ui_cancel")[0].keycode
		indicator_label.text = "[pulse freq=1.0 color=#ffffff40 ease=-2.0][ %s ] / [ %s ][/pulse]" % [
			OS.get_keycode_string(advance_keycode),
			OS.get_keycode_string(cancel_keycode),
		]
	
	indicator.modulate = Color(1, 1, 1, 1 if val else 0)

func get_total_character_count():
	return text_label.get_total_character_count()
