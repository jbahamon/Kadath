@tool
extends "./text_panel_container.gd"

var _text_label: Label

func _init():
	self.size_flags_horizontal = 0
	_text_label = Label.new()
	
func set_text(text: String):
	self._text_label.text = text
	self.update_outline_margin()
	
func get_content():
	return _text_label

func set_text_property(property_name, value):
	_text_label.set(property_name, value)
	self.update_outline_margin()

func get_outline_size():
	
	var settings = _text_label.label_settings
	if settings != null:
		return settings.outline_size
	else:
		return 0
