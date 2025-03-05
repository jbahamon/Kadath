extends MarginContainer

@onready var label = $Button/MarginContainer/Label

var save_slot

func _ready():
	self.update_item()
		
func assign_element(element):
	self.save_slot = element
	
func assign_null(_args: Dictionary):
	self.save_file = {
		"index": -1,
		"file": null
	}
	self.update_item()

func update_item():
	if self.save_slot == null:
		self.label.text = "Empty"
	else:
		self.label.text = "Save %s" % self.save_slot["index"]

func get_button():
	return $Button

func set_as_disabled(value):
	var color = get_theme_color("font_color_disabled" if value else "font_color", "Button")
	label.add_theme_color_override("font_color", color)
	$Button.disabled = value
