extends MarginContainer

var item_id: String
var amount: int

@onready var icon = $Button/MarginContainer/HBoxContainer/Icon
@onready var item_name_label = $Button/MarginContainer/HBoxContainer/ItemName
@onready var amount_label = $Button/MarginContainer/HBoxContainer/Amount

func _ready():
	
	if self.item_id != null:
		update_item()
		
func assign_element(element):
	self.item_id = element[0]
	self.amount = element[1]
	if self.is_inside_tree():
		self.update_item()

func assign_null(_args: Dictionary):
	self.item_id = ""
	self.amount = 0
	if self.is_inside_tree():
		self.update_item()

func update_item():
	var item = ItemService.id_to_item(self.item_id)
	self.item_name_label.text = item.display_name
	if item.max_amount == 1:
		self.amount_label.text = ""
	else:
		self.amount_label.text = "x%d" % amount

func get_button():
	return $Button

func set_as_disabled(value):
	var color = get_theme_color("font_color_disabled" if value else "font_color", "Button")
	$Button/MarginContainer/HBoxContainer/ItemName.add_theme_color_override("font_color", color)
	$Button/MarginContainer/HBoxContainer/Amount.add_theme_color_override("font_color", color)
	$Button.disabled = value
