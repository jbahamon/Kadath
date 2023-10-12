extends PanelContainer

signal swap_mode_toggled(mode)
var normal_button_style = load("res://ui/01_atoms/highlight/normal.tres")
var highlighted_button_style = load("res://ui/01_atoms/highlight/focus.tres")
var font_color_normal = Color(1, 1, 1, 1)
var font_color_highlighted = Color(0, 1, 1, 1)
var highlighted_index: int = -1

var in_swap_mode = false
@onready var use: Button = $VBoxContainer/ItemActions/Use
@onready var swap: Button = $VBoxContainer/ItemActions/Swap
@onready var toss: Button = $VBoxContainer/ItemActions/Toss
@onready var buttons = [use, swap, toss]

@onready var description: Label = $VBoxContainer/Description

func _on_item_focused(item: InventoryItem):

	description.text = item.description
	
	use.set_disabled(in_swap_mode or (not item.usable_outside_of_battle))
	swap.set_disabled(false)
	toss.set_disabled(in_swap_mode or (not item.tossable))
	
	if not in_swap_mode:
		for button in buttons:
			button.add_theme_stylebox_override("normal", normal_button_style)
			button.add_theme_color_override("font_color", font_color_normal)
		
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
		buttons[highlighted_index].add_theme_stylebox_override("normal", normal_button_style)
		buttons[highlighted_index].add_theme_color_override("font_color", font_color_normal)
		
	buttons[i].add_theme_stylebox_override("normal", highlighted_button_style)
	buttons[i].add_theme_color_override("font_color", font_color_highlighted)
	highlighted_index = i

func disable_swap_mode():
	# In order to do this manually, we have to disconnect, toggle and reconnect.
	swap.disconnect("toggled",Callable(self,"_on_Swap_toggled"))
	swap.button_pressed = false
	swap.connect("toggled",Callable(self,"_on_Swap_toggled"))

func click_action():
	var button: Button = buttons[highlighted_index]
	if button.toggle_mode:
		button.button_pressed = not button.button_pressed
	else:
		button.emit_signal("pressed")
	
func _on_Swap_toggled(button_pressed):
	in_swap_mode = button_pressed
	if in_swap_mode:
		use.disabled = true
		toss.disabled = true
		highlight(1)
	emit_signal("swap_mode_toggled", in_swap_mode)
