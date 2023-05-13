extends VBoxContainer

@export var popup_path: NodePath

@onready var saves: SavesPopup = $Popups/Saves
@onready var settings: Window = $Popups/Settings
@onready var new_game_button = $"VBoxContainer/Menu Options/New Game"
@onready var continue_button = $"VBoxContainer/Menu Options/Continue Game"


func _ready():
	saves.popup_window = false
	settings.popup_window = false
	
	if not saves.has_file_with_data():
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
	saves.popup_centered_ratio(1)

func _on_Settings_pressed():
	print(settings.exclusive)
	settings.popup_centered_ratio(1)

