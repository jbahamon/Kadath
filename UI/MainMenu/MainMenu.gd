extends VBoxContainer

export var popup_path: NodePath

var SaveData = load("res://SaveData.gd")

onready var saves_popup: PopupPanel = $Popups/SavesPopup
onready var input_popup: PopupPanel = $Popups/InputPopup
onready var new_game_button = $"VBoxContainer/Menu Options/New Game"
onready var continue_button = $"VBoxContainer/Menu Options/Continue Game"


func _ready():
	preload_save_files()
	
		
func preload_save_files():
	var save_filenames = SaveData.get_valid_save_filenames()
			
	if save_filenames.empty():
		continue_button.visible = false
		new_game_button.grab_focus()
		new_game_button.grab_click_focus()
	else:
		continue_button.grab_focus()
		continue_button.grab_click_focus()

	
func _on_Quit_pressed():
	get_tree().quit()


func _on_New_Game_pressed():
	start_game(SaveData.new())


func _on_Continue_Game_pressed():
	saves_popup.popup_centered_ratio()


func _on_PopupPanel_save_file_selected(filename):
	var save_data = SaveData.build_from_filename(filename)
	start_game(save_data)
	
func load_save_data(save_data):
	Inventory.load_save_data(save_data)
	PlayerVars.load_save_data(save_data)

	
func start_game(save_data):
	load_save_data(save_data)
	get_tree().change_scene("res://World/LocalScene.tscn")



func _on_Settings_pressed():
	input_popup.popup_centered_ratio(1)
