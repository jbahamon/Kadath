extends HBoxContainer

var item: InventoryItem
var _selected_while_unfocused = false
func _ready():
	if item != null:
		set_item(item)
		
		
func set_item(new_item: InventoryItem):
	if not self.is_inside_tree():
		return
		
	self.item = new_item
	
	$Icon.text = ""
	$ItemName.text = item.name
	
	if item.max_amount == 1:
		$Amount.text = ""
	else:
		$Amount.text = "x%d" % item.amount


func _on_ItemEntry_focus_entered():
	$Icon.text = ">"


func _on_ItemEntry_focus_exited():
	if _selected_while_unfocused:
		$Icon.text = "*"
	else:
		$Icon.text = ""
	
func set_selected_while_unfocused(val: bool):
	_selected_while_unfocused = val
