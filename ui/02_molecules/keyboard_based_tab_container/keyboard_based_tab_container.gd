extends VBoxContainer

class_name KeyboardBasedTabsContainer

signal cancel

const default_modulate = Color("#FFFFFF")

@export var tab_alignment: AlignmentMode = ALIGNMENT_BEGIN

@export var inactive_content_modulate = Color("#888888")
@export var normal_tab: StyleBox
@export var pressed_tab: StyleBox
@export var disabled_tab: StyleBox
@export var hover_tab: StyleBox
@export var focused_tab: StyleBox

@export var normal_font_color: Color
@export var clicked_font_color: Color
@export var disabled_font_color: Color
@export var focused_font_color: Color

@export var content_style: StyleBox

var overlay: Container
var tabs_container: HBoxContainer
var content_container: Container
var tabs_button_group: ButtonGroup

var current_content: Control

func _ready():
	var children = pop_children()
	build_tabs_container()
	build_content_container()
	build_tabs(children)
	assign_tab_neighbours()
	
	
func initialize():
	for child in content_container.get_children():
		if child.has_method("initialize"):
			child.initialize()
		

func pop_children():
	var children = get_children()
	
	for child in children:
		remove_child(child)
	
	return children

func build_tabs_container():
	tabs_container = HBoxContainer.new()
	tabs_container.name = "TabBar"
	tabs_container.alignment = tab_alignment
	tabs_container.size_flags_vertical = SIZE_SHRINK_CENTER
	tabs_container.size_flags_horizontal = SIZE_EXPAND_FILL
	self.add_child(tabs_container)

func build_content_container():
	var container = MarginContainer.new()
	container.name = "Container"
	container.size_flags_horizontal = SIZE_EXPAND_FILL
	container.size_flags_vertical = SIZE_EXPAND_FILL
	
	overlay = CenterContainer.new()
	overlay.name = "Overlay"
	overlay.size_flags_horizontal = SIZE_EXPAND_FILL
	overlay.size_flags_vertical = SIZE_EXPAND_FILL
	
	content_container = VBoxContainer.new()
	content_container.name = "Content"
	content_container.size_flags_horizontal = SIZE_EXPAND_FILL
	content_container.size_flags_vertical = SIZE_EXPAND_FILL
	content_container.modulate = inactive_content_modulate
	
	container.add_child(content_container)
	container.add_child(overlay)
	
	self.add_child(container)

func build_tabs(children: Array):
	tabs_button_group = ButtonGroup.new()
	for child in children:
		child.visible = false
		content_container.add_child(child)
		var tab_button = build_tab_button_for(child)
		tabs_container.add_child(tab_button)

		
func build_tab_button_for(child: Control):
	
	var button = Button.new()
	button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if normal_tab != null:
		button.add_theme_stylebox_override("normal", normal_tab)
	if pressed_tab != null:
		button.add_theme_stylebox_override("pressed", pressed_tab)
	if disabled_tab != null:
		button.add_theme_stylebox_override("disabled", disabled_tab)
	if hover_tab != null:
		button.add_theme_stylebox_override("hover", hover_tab)
	if focused_tab != null:
		button.add_theme_stylebox_override("focus", focused_tab)

	if "icon" in child:
		button.icon = child.icon
		
	
	button.text = child.name
	button.toggle_mode = true
	button.button_group = tabs_button_group
	
	button.focus_entered.connect(self.on_button_focused.bind(button))
	button.toggled.connect(self.on_content_toggled.bind(child))
	
	return button

func assign_tab_neighbours():
	var buttons = tabs_container.get_children().filter(func(child): return not child.disabled)

	for i in range(len(buttons)):
		var button = buttons[i]
		button.focus_neighbor_top = button.get_path_to(button)
		button.focus_neighbor_bottom = button.get_path_to(button)
		button.focus_neighbor_left = button.get_path_to(buttons[posmod((i - 1), len(buttons))])
		button.focus_neighbor_right = button.get_path_to(buttons[posmod((i + 1), len(buttons))])
	
func reset():
	var buttons = tabs_button_group.get_buttons()
	if buttons.is_empty():
		return
		
	overlay.visible = false
	
	for button in buttons:
		if not button.disabled:
			button.button_pressed = true
			button.grab_click_focus()
			button.grab_focus()
			return
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		var pressed_tab_button = tabs_button_group.get_pressed_button()
		if pressed_tab_button.has_focus() and current_content.has_method("on_grab_focus"):
			overlay.visible = false
			current_content.on_grab_focus()
			content_container.modulate = default_modulate
			get_viewport().set_input_as_handled()
	elif (event.is_action_pressed("ui_cancel") and 
			tabs_button_group.get_pressed_button() != null and  
			tabs_button_group.get_pressed_button().has_focus()):
		self.cancel.emit()
		self.get_viewport().set_input_as_handled()

func focus_current_tab():
	var pressed_tab_button = tabs_button_group.get_pressed_button()
	overlay.visible = "icon" in current_content
	if current_content.has_method("on_release_focus"):
		current_content.on_release_focus()
	pressed_tab_button.grab_click_focus()
	pressed_tab_button.grab_focus()
	content_container.modulate = inactive_content_modulate

func on_button_focused(button: Button):
	button.button_pressed = true

func on_content_toggled(toggled: bool, content: Control):
	content.visible = toggled
	
	if toggled:
		overlay.visible = "icon" in content
		current_content = content
		current_content.size_flags_horizontal = SIZE_EXPAND_FILL
		current_content.size_flags_vertical = SIZE_EXPAND_FILL

func set_tab_disabled(i: int, value: bool):
	var tab_button: Button = tabs_container.get_child(i)
	if tab_button.has_focus():
		var new_focused_node = tab_button.get_node(tab_button.focus_neighbor_right)
		new_focused_node.grab_focus()
		new_focused_node.grab_click_focus()
		
	tab_button.focus_mode = Control.FOCUS_NONE
	tab_button.disabled = value
	tab_button.button_group = tabs_button_group if value else null
	assign_tab_neighbours()

func set_current_tab(i: int):
	tabs_container.get_child(i).button_pressed = true
