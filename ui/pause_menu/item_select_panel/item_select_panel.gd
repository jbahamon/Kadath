extends PanelContainer

signal item_focused(item)
signal item_selected(item)

onready var container = $ScrollContainer/VBoxContainer 

var property_to_assign: String

func initialize(items: Array):
	if items.size() == 0:
		return
	
	for item in items:
		var button = Button.new()
		button.text = item.name
		
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.connect("pressed", self, "on_item_selected", [item])
		button.connect("focus_entered", self, "on_item_focused", [item])
		container.add_child(button)
		
		button.focus_neighbour_left = button.get_path_to(button)
		button.focus_neighbour_right = button.get_path_to(button)
		
	var last_button: Button = container.get_child(container.get_child_count() - 1)
	last_button.focus_neighbour_bottom = last_button.get_path_to(last_button)
	
	var first_button: Button = container.get_child(0)
	first_button.focus_neighbour_top = first_button.get_path_to(first_button)
	
	first_button.grab_click_focus()
	first_button.grab_focus()

	
func on_item_focused(item):
	emit_signal("item_focused", item)
		
func on_item_selected(item):
	self.clear_items()
	emit_signal("item_selected", item)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		self.clear_items()
		emit_signal("item_selected", null)
		get_tree().set_input_as_handled()

func clear_items():
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
		
