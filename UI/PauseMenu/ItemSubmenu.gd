extends VSplitContainer

var item_entry_scene = preload("res://UI/PauseMenu/ItemEntry.tscn")
onready var browse: Button = $ActionsPanel/ActionsHBox/Browse
onready var autosort: Button = $ActionsPanel/ActionsHBox/Autosort
onready var items: Container = $SplitPanel/ItemsPanel/ItemsScroll/Items
onready var use_and_description = $SplitPanel/ItemUseAndDescription

var browsing = false

func _ready():
	Inventory.update_test_items()
	set_process_input(false)
	update_items()

func _on_Browse_pressed():
	browsing = true
	browse.disabled = true
	autosort.disabled = true
	
	for item in items.get_children():
		item.focus_mode = Control.FOCUS_ALL
		
	if items.get_child_count() > 0:
		var first_item = items.get_child(0)
		first_item.grab_focus()
		first_item.grab_click_focus()
		
	set_process_input(true)


func _on_Autosort_pressed():
	Inventory.sort()
	update_items()

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		browsing = false
		browse.disabled = false
		autosort.disabled = false
		
		browse.grab_focus()
		browse.grab_click_focus()
			
		for item in items.get_children():
			item.focus_mode = Control.FOCUS_NONE
		
		use_and_description.clear()
		set_process_input(false)
		
	elif event.is_action_pressed("ui_left"):
		use_and_description._on_left()
	elif event.is_action_pressed("ui_right"):
		use_and_description._on_right()


func update_items():
	remove_all_items()
	add_all_items()
	set_item_neighbours()


func add_all_items():
	for i in range(len(Inventory.current_items)):
		var item = Inventory.current_items[i]
		var new_item_entry = item_entry_scene.instance()
		
		items.add_child(new_item_entry)
		new_item_entry.set_item(item)
		new_item_entry.focus_mode = Control.FOCUS_NONE
		new_item_entry.connect(
				"focus_entered",
				use_and_description,
				"_on_item_focused",
				[i, item]
		)


func remove_all_items():
	for item in items.get_children():
		items.remove_child(item)
		item.queue_free()


func set_item_neighbours():
	var children = items.get_children()
	for i in range(len(children)):
		var item_entry: Control = children[i]
		
		item_entry.focus_neighbour_top = children[(i - 1) % len(children)].get_path()
		item_entry.focus_neighbour_bottom = children[(i + 1) % len(children)].get_path()
		
		item_entry.focus_neighbour_left = item_entry.get_path()
		item_entry.focus_neighbour_right = item_entry.get_path()
