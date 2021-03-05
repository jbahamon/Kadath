extends PanelContainer

signal swap_mode_toggled(mode)
var normal_button_style = load("res://PixelInterface/Style/Button.tres")
var highlighted_button_style = load("res://PixelInterface/Style/ButtonHover.tres")
var highlighted_index: int = -1

var in_swap_mode = false
onready var use: Button = $VBoxContainer/ItemActions/Use
onready var swap: Button = $VBoxContainer/ItemActions/Swap
onready var toss: Button = $VBoxContainer/ItemActions/Toss
onready var buttons = [use, swap, toss]

onready var description: Label = $VBoxContainer/Description

func _on_item_focused(item: InventoryItem):

	description.text = item.description
	
	use.set_disabled(in_swap_mode or item.usable_outside_of_battle)
	swap.disabled = false
	toss.set_disabled(in_swap_mode or item.category == InventoryItem.ItemCategory.QUEST)
	
	if not in_swap_mode:
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
	in_swap_mode = false
	for button in buttons:
		button.disabled = true
	highlighted_index = -1
	description.text = ""
	
	
func _on_left():
	move(-1)
	
	
func _on_right():
	move(1)
	
	
func move(increment: int):
	if in_swap_mode or highlighted_index < 0:
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

func disable_swap_mode():
	# In order to do this manually, we have to disconnect, toggle and reconnect.
	swap.disconnect("toggled", self, "_on_Swap_toggled")
	swap.pressed = false
	swap.connect("toggled", self, "_on_Swap_toggled")

func click_action():
	var button: Button = buttons[highlighted_index]
	if button.toggle_mode:
		button.pressed = not button.pressed
	else:
		button.emit_signal("pressed")
	
func _on_Swap_toggled(button_pressed):
	in_swap_mode = button_pressed
	if in_swap_mode:
		use.disabled = true
		toss.disabled = true
		highlight(1)
	emit_signal("swap_mode_toggled", in_swap_mode)
