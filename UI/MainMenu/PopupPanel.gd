extends PopupPanel

signal save_file_selected(filename)

var current_filenames = []

onready var v_box: VBoxContainer = $Scroll/SavesList

func update_options(filenames):
	
	for child in v_box.get_children():
		v_box.remove_child(child)
		child.queue_free()
	
	current_filenames = filenames
		
	for i in range(len(filenames)):
		var new_button = Button.new()
		
		new_button.text = "File %d" % (i + 1)
		new_button.connect("pressed", self, "_on_button_pressed", [i])
		v_box.add_child(new_button)

func _on_button_pressed(index):
	emit_signal("save_file_selected", current_filenames[index])


func _on_PopupPanel_about_to_show():
	self.update_options(SaveData.get_valid_save_filenames())
