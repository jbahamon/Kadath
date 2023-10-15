extends MarginContainer

var disabled = false
var item_id: String
var _selected_while_unfocused = false
var amount: int

@onready var bg = $NinePatch
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

func assign_null(args: Dictionary):
	self.item_id = ""
	self.amount = 0
	if self.is_inside_tree():
		self.update_item()

func update_item():
	var item = ItemService.id_to_item(self.item_id)
	self.item_name_label.text = item.name
	if item.max_amount == 1:
		self.amount_label.text = ""
	else:
		self.amount_label.text = "x%d" % amount

func get_button():
	return $Button
	
