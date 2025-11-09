extends Container

class_name SavesMenu

var save_item = preload("res://ui/02_molecules/saves_list_item/saves_list_item.tscn")

const titles = {
	SavesService.SaveAccessMode.LOAD: "Choose a save file to load.",
	SavesService.SaveAccessMode.SAVE: "Choose a save file to save to.",
}

@export var current_mode: SavesService.SaveAccessMode = SavesService.SaveAccessMode.LOAD
@onready var list = $VBoxContainer/SelectList
@onready var confirmation_popup: Popup = $ConfirmationPopup

var current_save_spot_name: String

func _ready():
	self.update_menu(true)

func show_menu():
	self.show()

func hide_menu():
	self.hide()

func update_menu(force_load=false):
	var new_file_previews = SavesService.get_file_previews(force_load)
	self.list.initialize(new_file_previews, {
		"class_or_scene": save_item,
		"disable_func": func(save_slot):
			return self.current_mode == SavesService.SaveAccessMode.LOAD && save_slot["file"] == null
	})

func set_spot_name(save_spot_name):
	self.current_save_spot_name = save_spot_name
	
func _save_selected(save_slot):
	if current_mode == SavesService.SaveAccessMode.SAVE:
		if save_slot["file"] != null:
			confirmation_popup.popup_centered_clamped()
			var ok = await confirmation_popup.confirmed
			
			if not ok:
				self.list.on_grab_focus(save_slot["index"])
				return

		SavesService.save_game_data(self.current_save_spot_name, save_slot["index"])
		self.update_menu()
		self.list.on_grab_focus(save_slot["index"])
		
	else:
		SavesService.loaded_slot = save_slot["index"]
		SceneSwitcher.load_scene("res://main/local_scene.tscn")
		SceneSwitcher.switch_scene()

func _on_visibility_changed() -> void:
	if self.visible or self.is_visible_in_tree():
		self.update_menu(false)
		$VBoxContainer/Title/Label.text = titles[self.current_mode]
		UIService.set_menu_help(
			"",
			"[{ui_up}]/[{ui_down}]: Select [{ui_cancel}]: Return [{ui_accept}]: Confirm"
		)
		self.list.on_grab_focus()
