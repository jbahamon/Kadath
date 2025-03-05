extends MarginContainer

class_name SavesPopup

var save_item = preload("res://ui/02_molecules/saves_list_item/saves_list_item.tscn")

enum SaveAccessMode {SAVE, LOAD}

@export var current_mode: SaveAccessMode = SaveAccessMode.LOAD
@onready var list = $SelectList
@onready var confirmation_popup: Popup = $ConfirmationPopup

func _ready():
	self.update_menu()

func show_menu():
	self.show()

func hide_menu():
	self.hide()

func update_menu():
	var new_file_previews = SavesService.get_file_previews()
	self.list.initialize(new_file_previews, {
		"class_or_scene": save_item,
		"disable_func": func(save_slot):
			return self.current_mode == SaveAccessMode.LOAD && save_slot["file"] == null
	})

func _save_selected(save_slot):
	if current_mode == SaveAccessMode.SAVE:
		if save_slot["file"] != null:
			confirmation_popup.popup_centered_clamped()
			var ok = await confirmation_popup.closed
			
			if not ok:
				return
			
		SavesService.save(save_slot["index"])
		self.update_menu()
			
	else:
		VarsService.loaded_slot = save_slot["index"]
		SceneSwitcher.go_to_scene("res://main/local_scene.tscn")
