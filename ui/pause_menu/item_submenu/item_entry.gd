extends HBoxContainer

var item: InventoryItem
var amount: int
var _selected_while_unfocused = false


func _ready():
	if self.item != null:
		update_item()
		
		
func set_item(new_item: InventoryItem, amount: int):
	self.item = new_item
	self.amount = amount
	if self.is_inside_tree():
		self.update_item()
		

func update_item():
	$Icon.text = ""
	$ItemName.text = item.name
	
	if item.max_amount == 1:
		$Amount.text = ""
	else:
		$Amount.text = "x%d" % amount


func _on_ItemEntry_focus_entered():
	$Icon.text = ">"


func _on_ItemEntry_focus_exited():
	if _selected_while_unfocused:
		$Icon.text = "*"
	else:
		$Icon.text = ""
	
func set_selected_while_unfocused(val: bool):
	_selected_while_unfocused = val
