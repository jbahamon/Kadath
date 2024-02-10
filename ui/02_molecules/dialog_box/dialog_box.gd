extends PanelContainer

@onready var text_label = $MarginContainer/HBoxContainer/RichTextLabel
@onready var indicator = $MarginContainer/HBoxContainer/VBoxContainer/TextureRect
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
	indicator.modulate = Color(1, 1, 1, 1 if val else 0)

func get_total_character_count():
	return text_label.get_total_character_count()
