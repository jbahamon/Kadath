extends MarginContainer

var item: InventoryItem
var _selected_while_unfocused = false
var amount: int

var modulate_bg = Color("a7591b")
var modulate_invisible = Color(0, 0, 0, 0)

var modulate_none = Color(1, 1, 1, 1)
var modulate_swap = Color(1, 1, 0, 1)
var modulate_focus = Color(0, 1, 1, 1)

onready var bg = $NinePatch
onready var box = $MarginContainer/HBoxContainer
onready var icon = $MarginContainer/HBoxContainer/Icon
onready var item_name_label = $MarginContainer/HBoxContainer/ItemName
onready var amount_label = $MarginContainer/HBoxContainer/Amount

func _ready():
	
	if self.item != null:
		update_item()
		
		
func set_item(new_item: InventoryItem, amount: int):
	self.item = new_item
	self.amount = amount
	if self.is_inside_tree():
		self.update_item()
		

func update_item():
	item_name_label.text = item.name
	
	if item.max_amount == 1:
		amount_label.text = ""
	else:
		amount_label.text = "x%d" % amount


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
