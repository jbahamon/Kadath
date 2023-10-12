extends MarginContainer

var disabled = false
var item_id: String
var _selected_while_unfocused = false
var amount: int

var modulate_bg = Color("a7591b")
var modulate_invisible = Color(0, 0, 0, 0)

var modulate_none = Color(1, 1, 1, 1)
var modulate_swap = Color(1, 1, 0, 1)
var modulate_focus = Color(0, 1, 1, 1)

@onready var bg = $NinePatch
@onready var box = $Button/HBoxContainer
@onready var icon = $Button/HBoxContainer/Icon
@onready var item_name_label = $Button/HBoxContainer/ItemName
@onready var amount_label = $Button/HBoxContainer/Amount

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

func _on_ItemEntry_focus_entered():
	self.bg.self_modulate = modulate_bg
	self.box.modulate = modulate_focus


func _on_ItemEntry_focus_exited():
	self.bg.self_modulate = modulate_invisible
	if _selected_while_unfocused:
		self.box.modulate = modulate_swap
	else:
		self.box.modulate = modulate_none
	
func set_selected_while_unfocused(val: bool):
	_selected_while_unfocused = val
