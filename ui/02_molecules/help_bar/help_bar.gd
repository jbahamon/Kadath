extends PanelContainer

@onready var help_label: Label = $HBoxContainer/Help
@onready var controls_label: Label = $HBoxContainer/Controls

func set_help(help_text: String, controls_text: String):
	self.help_label.text = help_text
	self.controls_label.text = controls_text.format(VarsService.strings)

func set_visible_ratio(ratio: float):
	self.help_label.visible_ratio = ratio

func get_total_character_count():
	return self.help_label.get_total_character_count()
	
func set_text(text):
	self.help_label.text = text
