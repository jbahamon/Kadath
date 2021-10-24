extends VSplitContainer

var item_entry_scene = preload("res://ui/pause_menu/item_submenu/item_entry.tscn")
onready var items: Container = $SplitPanel/ItemsPanel/ItemsScroll/Items
onready var use_and_description = $SplitPanel/ItemUseAndDescription
onready var use_description_panel: PanelContainer = $SplitPanel/ItemUseAndDescription

export var icon: Texture 

var in_swap_mode = false
var focused_index: int
var index_for_swap: int = -1
var inventory: Inventory = null

func _ready():
	self.set_process_unhandled_input(false)
	self.set_process_input(false)
	self.focus_mode = Control.FOCUS_ALL
	
	
func initialize(party: Party):
	if self.inventory != null:
		self.inventory.disconnect("inventory_changed", self, "on_inventory_changed")
	self.inventory = party.inventory
	self.inventory.connect("inventory_changed", self, "on_inventory_changed")
	
	update_items()

func autosort():
	inventory.sort()

func _on_swap_mode_toggled(swap_mode):
	in_swap_mode = swap_mode
	var new_focused_item
	if in_swap_mode:
		new_focused_item = items.get_child(focused_index)
		index_for_swap = focused_index
	else:
		new_focused_item = items.get_child(index_for_swap)
		perform_swap()
		
	new_focused_item.set_selected_while_unfocused(in_swap_mode)
	new_focused_item.grab_focus()
	new_focused_item.grab_click_focus()
	
	
func perform_swap():
	inventory.swap_items(index_for_swap, focused_index)
	swap_item_entries(index_for_swap, focused_index)
	index_for_swap = -1
	
func swap_item_entries(i1, i2):
	if i1 == i2:
		return
	var first = min(i1, i2)
	var second = max(i1, i2)
	
	var first_child = items.get_child(first)
	var second_child = items.get_child(second)
	items.move_child(items.get_child(first), second)
	items.move_child(items.get_child(second - 1), first)
	
	first_child.disconnect("focus_entered", self, "_on_index_focused")
	second_child.disconnect("focus_entered", self, "_on_index_focused")

	first_child.connect("focus_entered", self, "_on_index_focused", [second])
	second_child.connect("focus_entered", self, "_on_index_focused", [first])
	
	set_all_item_neighbours()
	
func _on_index_focused(index):
	focused_index = index
	
func _input(event: InputEvent):
	if in_swap_mode:
		on_swap_input(event)
	else:
		on_browse_input(event)

func on_swap_input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		use_and_description.disable_swap_mode()
		var original_item = items.get_child(index_for_swap)
		original_item.set_selected_while_unfocused(false)
		original_item.grab_focus()
		original_item.grab_click_focus()
		
		index_for_swap = -1
		in_swap_mode = false
		
	elif event.is_action_pressed("ui_accept"):
		use_and_description.click_action()
	else:
		return
		
	get_tree().set_input_as_handled()

func on_browse_input(event: InputEvent):
	if event.is_action_pressed("ui_left"):
		use_and_description._on_left()
	elif event.is_action_pressed("ui_right"):
		use_and_description._on_right()
	elif event.is_action_pressed("ui_accept"):
		use_and_description.click_action()
	else:
		return
		
	get_tree().set_input_as_handled()

func on_inventory_changed(change_type):
	if change_type != Inventory.Change.SWAP:
		update_items()
	
func update_items():
	remove_all_items()
	add_all_items()
	set_all_item_neighbours()
	
	if self.items.get_child_count() > 0:
		self.focus_mode = Control.FOCUS_NONE
	else:
		self.focus_mode = Control.FOCUS_ALL
	
	self.reset_focus()

func add_all_items():
	for i in range(len(self.inventory.order)):
		var item = self.inventory.order[i]
		var new_item_entry = item_entry_scene.instance()
		
		items.add_child(new_item_entry)
		new_item_entry.set_item(item, inventory.amounts[item])
		new_item_entry.focus_mode = Control.FOCUS_ALL
		new_item_entry.connect(
			"focus_entered",
			use_and_description,
			"_on_item_focused",
			[item]
		)
		
		new_item_entry.connect(
			"focus_entered",
			self,
			"_on_index_focused",
			[i]
		)


func remove_all_items():
	for item in items.get_children():
		items.remove_child(item)
		item.queue_free()


func set_all_item_neighbours():
	var children = items.get_children()
	for i in range(len(children)):
		set_item_neighbours(i, children)
		
		
func set_item_neighbours(i: int, children: Array):
	var item_entry: Control = children[i]
	
	item_entry.focus_neighbour_top = item_entry.get_path_to(children[posmod((i - 1), len(children))])
	item_entry.focus_neighbour_bottom = item_entry.get_path_to(children[posmod((i + 1),  len(children))])
	
	item_entry.focus_neighbour_left = item_entry.get_path_to(item_entry)
	item_entry.focus_neighbour_right = item_entry.get_path_to(item_entry)


func receive_focus():
	self.reset_focus()
	self.set_process_unhandled_input(true)
	self.set_process_input(true)
	
	return true


func relinquish_focus():
	self.set_process_unhandled_input(false)
	self.set_process_input(false)


func reset_focus():
	var element_to_focus
	if items.get_child_count() > 0:
		element_to_focus = items.get_child(0)
	else:
		element_to_focus = self
		
	element_to_focus.grab_focus()
	element_to_focus.grab_click_focus()
	
