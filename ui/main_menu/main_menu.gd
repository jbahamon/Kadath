extends VBoxContainer

export var popup_path: NodePath

onready var saves_popup: SavesPopup = $Popups/SavesPopup
onready var input_popup: PopupPanel = $Popups/InputPopup
onready var new_game_button = $"VBoxContainer/Menu Options/New Game"
onready var continue_button = $"VBoxContainer/Menu Options/Continue Game"


func _ready():
	
	if not saves_popup.has_file_with_data():
		continue_button.visible = false
		new_game_button.grab_focus()
		new_game_button.grab_click_focus()
	else:
		continue_button.grab_focus()
		continue_button.grab_click_focus()
	
func _on_Quit_pressed():
	get_tree().quit()

func _on_New_Game_pressed():
	SceneSwitcher.go_to_scene("res://main/local_scene.tscn")

func _on_Continue_Game_pressed():
	saves_popup.popup_centered_ratio()

func _on_Settings_pressed():
	input_popup.popup_centered_ratio(1)

