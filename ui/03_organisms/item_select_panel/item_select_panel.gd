extends MarginContainer

signal item_focused(item)
signal item_selected(item)

@onready var container = $ScrollContainer/VBoxContainer 
@onready var cancel_button = $ScrollContainer/VBoxContainer/CancelButton

var property_to_assign: String

func _ready():
	self.set_process_unhandled_input(false)
	
func initialize(items: Array):
	for item in items:
		var button = Button.new()
		button.text = item.name
		
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.pressed.connect(self.on_item_selected.bind(item))
		button.focus_entered.connect(self.on_item_focused.bind(item))
		container.add_child(button)
		
		button.focus_neighbor_left = button.get_path_to(button)
		button.focus_neighbor_right = button.get_path_to(button)
	
	container.move_child(cancel_button, items.size())
	
	var first_button: Button = container.get_child(0)
	var last_button: Button = container.get_child(container.get_child_count() - 1)
	
	first_button.focus_neighbor_top = first_button.get_path_to(last_button)
	last_button.focus_neighbor_bottom = last_button.get_path_to(first_button)
	
	first_button.grab_click_focus()
	first_button.grab_focus()

	
func on_item_focused(item):
	self.item_focused.emit(item)
		
func on_item_selected(item):
	self.clear_items()
	self.item_selected.emit(item)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		self.on_cancel()
		self.get_viewport().set_input_as_handled()

func on_cancel():
	self.clear_items()
	self.item_selected.emit(null)
	
func clear_items():
	self.set_process_unhandled_input(false)
	for child in container.get_children():
		if child != cancel_button:
			container.remove_child(child)
			child.queue_free()
		
