extends PopupPanel

class_name SavesPopup

signal save_file_selected(index)

enum Mode {SAVE, LOAD}

export(Mode) var current_mode: int = Mode.LOAD

var selected_index: int = -1
var file_previews = []

onready var v_box: VBoxContainer = $Scroll/SavesList
onready var confirmation_popup: Popup = $ConfirmationPopup

func _ready():
	self.update_options()

func _gui_input(event):
	if event.is_action_pressed("ui_cancel"):
		hide()

		
func update_options():
	var new_file_previews = SaveData.get_file_previews()
	for child in v_box.get_children():
		v_box.remove_child(child)
		child.queue_free()
	
	file_previews = new_file_previews
	
	var first_focusable = null	
	for i in range(len(file_previews)):
		var new_button = Button.new()
		
		if file_previews[i] != null:
			new_button.text = "File %d" % (i + 1)
		else:
			new_button.text = "No data"
			new_button.disabled = current_mode == Mode.LOAD
			new_button.focus_mode = Control.FOCUS_NONE if current_mode == Mode.LOAD else Control.FOCUS_ALL
		
		if current_mode == Mode.SAVE or file_previews[i] != null:
			new_button.connect("pressed", self, "_on_button_pressed", [i])
			
		if first_focusable == null and not new_button.disabled:
			first_focusable = new_button
		
		v_box.add_child(new_button)

	if first_focusable != null:
		first_focusable.grab_focus()
		first_focusable.grab_click_focus()

func _on_button_pressed(index):
	emit_signal("save_file_selected", index)
	selected_index = index
	if current_mode == Mode.SAVE:
		if file_previews[index] != null:
			confirmation_popup.popup_centered_minsize()
		else:
			save_to_file(index)

func has_file_with_data():
	for item in file_previews:
		if item != null:
			return true
	return false

func _on_ConfirmationPopup_confirmed():
	save_to_file(selected_index)

func save_to_file(save_file_index):
	if current_mode == Mode.SAVE:
		var current_save_data = SaveData.new()
		current_save_data.init_from_current_state()
		current_save_data.save_to_slot(save_file_index)
		update_options()
		