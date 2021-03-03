extends PanelContainer

var normal_button_style = load("res://PixelInterface/Style/Button.tres")
var highlighted_button_style = load("res://PixelInterface/Style/ButtonHover.tres")
var highlighted_index: int = -1

onready var buttons = [
	$VBoxContainer/ItemActions/Use,
	$VBoxContainer/ItemActions/Swap,
	$VBoxContainer/ItemActions/Toss,
]

onready var description: Label = $VBoxContainer/Description

func _on_item_focused(index: int, item: InventoryItem):
	
	description.text = item.description
	
	# use button
	buttons[0].set_disabled(item.usable_outside_of_battle)
	
	# swap button
	buttons[1].disabled = false
	
	# toss button
	buttons[2].set_disabled(item.category == InventoryItem.ItemCategory.QUEST)
	
	for button in buttons:
		button.add_stylebox_override("normal", normal_button_style)
	
	if highlighted_index < 0 or buttons[highlighted_index].disabled:
		for i in range(len(buttons)):	
			if not buttons[i].disabled:
				highlight(i)
				break
	else:
		highlight(highlighted_index)
		
		
func clear():
	for button in buttons:
		button.disabled = true
	highlighted_index = -1
	description.text = ""
	
	
func _on_left():
	move(-1)
	
	
func _on_right():
	move(1)
	
	
func move(increment: int):
	if highlighted_index < 0:
		return
		
	var new_index =	highlighted_index
	while true:
		new_index = posmod((new_index + increment), len(buttons))
		if not buttons[new_index].disabled:
			highlight(new_index)
			return
		elif highlighted_index == new_index:
			return


func highlight(i: int):
	if highlighted_index >= 0:
		buttons[highlighted_index] .add_stylebox_override("normal", normal_button_style)
		
	buttons[i].add_stylebox_override("normal", highlighted_button_style)
	highlighted_index = i
	
