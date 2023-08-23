extends PanelContainer

@onready var text_label = $MarginContainer/RichTextLabel

func set_text(text: String):
	if text != '':
		self.show()
		text_label.text = text
	else:
		self.hide()
