extends PanelContainer

@onready var text_label = $MarginContainer/RichTextLabel

func set_text(text: String):
	if text != '':
		self.show()
		text_label.text = text
	else:
		self.hide()
	
func set_visible_ratio(ratio: float):
	text_label.visible_ratio = ratio

func get_total_character_count():
	return text_label.get_total_character_count()
